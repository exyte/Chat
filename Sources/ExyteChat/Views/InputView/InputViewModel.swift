//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import ExyteMediaPicker

@MainActor
final class InputViewModel: ObservableObject {

    @Published var text = ""
    @Published var attachments = InputViewAttachments()
    @Published var state: InputViewState = .empty

    @Published var showPicker = false
  
    @Published var mediaPickerMode = MediaPickerMode.photos

    @Published var showActivityIndicator = false

    var recordingPlayer: RecordingPlayer?
    var didSendMessage: ((DraftMessage) -> Void)?

    private var recorder = Recorder()

    private var saveEditingClosure: ((String) -> Void)?

    private var recordPlayerSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    
    func setRecorderSettings(recorderSettings: RecorderSettings = RecorderSettings()) {
        Task {
            await self.recorder.setRecorderSettings(recorderSettings)
        }
    }

    func onStart() {
        subscribeValidation()
        subscribePicker()
    }

    func onStop() {
        subscriptions.removeAll()
    }

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.showPicker = false
            self?.text = ""
            self?.saveEditingClosure = nil
            self?.attachments = InputViewAttachments()
            self?.subscribeValidation()
            self?.state = .empty
        }
    }

    func send() {
        Task {
            await recorder.stopRecording()
            await recordingPlayer?.reset()
            sendMessage()
        }
    }

    func edit(_ closure: @escaping (String) -> Void) {
        saveEditingClosure = closure
        state = .editing
    }

    func inputViewAction() -> (InputViewAction) -> Void {
        { [weak self] in
            self?.inputViewActionInternal($0)
        }
    }
    
    private func inputViewActionInternal(_ action: InputViewAction) {
        switch action {
        case .photo:
            mediaPickerMode = .photos
            showPicker = true
        case .add:
            mediaPickerMode = .camera
        case .camera:
            mediaPickerMode = .camera
            showPicker = true
        case .send:
            send()
        case .recordAudioTap:
            Task { [weak self] in
                guard let self else { return }

                if await recorder.isRecording {
                    await stopRecording()
                } else {
                    state = await recorder.isAllowedToRecordAudio ? .isRecordingHold : .waitingForRecordingPermission
                    recordAudio()
                }
            }
        case .recordAudioHold:
            Task { [weak self] in
                guard let self else { return }

                guard !(await recorder.isRecording) else { return }
                state = await recorder.isAllowedToRecordAudio ? .isRecordingHold : .waitingForRecordingPermission
                recordAudio()
            }
        case .recordAudioLock:
            break
        case .stopRecordAudio:
            Task { [weak self] in
                await self?.stopRecording()
            }
        case .deleteRecord:
            Task {
                unsubscribeRecordPlayer()
                await recorder.stopRecording()
                attachments.recording = nil
            }
        case .playRecord:
            state = .playingRecording
            if let recording = attachments.recording {
                Task {
                    subscribeRecordPlayer()
                    await recordingPlayer?.play(recording)
                }
            }
        case .pauseRecord:
            state = .pausedRecording
            Task {
                await recordingPlayer?.pause()
            }
        case .saveEdit:
            saveEditingClosure?(text)
            reset()
        case .cancelEdit:
            reset()
        }
    }

    private func recordAudio() {
        Task { @MainActor [weak self, recorder] in
            guard let self else { return }

            if await recorder.isRecording { return }

            let recording = Recording()
            attachments.recording = recording

            let url = await recorder.startRecording { duration, samples in
                DispatchQueue.main.async { [weak self] in
                    self?.attachments.recording?.duration = duration
                    self?.attachments.recording?.waveformSamples = samples
                }
            }

            guard let url else {
                attachments.recording = nil
                if state == .isRecordingHold || state == .waitingForRecordingPermission {
                    state = .empty
                }
                return
            }

            if state == .waitingForRecordingPermission {
                state = .isRecordingHold
            }

            attachments.recording?.url = url
        }
    }

    private func stopRecording() async {
        await recorder.stopRecording()
        if let _ = attachments.recording {
            state = .hasRecording
        } else if state == .isRecordingHold || state == .waitingForRecordingPermission {
            state = .empty
        }
        await recordingPlayer?.reset()
    }
}

private extension InputViewModel {

    func validateDraft() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard state != .editing else { return } // special case
            if !self.text.isEmpty || !self.attachments.medias.isEmpty {
                self.state = .hasTextOrMedia
            } else if self.text.isEmpty,
                      self.attachments.medias.isEmpty,
                      self.attachments.recording == nil {
                self.state = .empty
            }
        }
    }

    func subscribeValidation() {
        $attachments.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)

        $text.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)
    }

    func subscribePicker() {
        $showPicker
            .sink { [weak self] value in
                if !value {
                    self?.attachments.medias = []
                }
            }
            .store(in: &subscriptions)
    }

    func subscribeRecordPlayer() {
        Task { @MainActor in
            if let recordingPlayer {
                recordPlayerSubscription = recordingPlayer.didPlayTillEnd
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        self?.state = .hasRecording
                    }
            }
        }
    }

    func unsubscribeRecordPlayer() {
        recordPlayerSubscription = nil
    }
}

private extension InputViewModel {

    func sendMessage() {
        showActivityIndicator = true
        let draft = DraftMessage(
            text: self.text,
            medias: attachments.medias,
            recording: attachments.recording,
            replyMessage: attachments.replyMessage,
            createdAt: Date()
        )
        didSendMessage?(draft)
        DispatchQueue.main.async { [weak self] in
            self?.showActivityIndicator = false
            self?.reset()
        }
    }
}
