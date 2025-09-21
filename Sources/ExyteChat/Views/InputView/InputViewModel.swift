//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import Observation
import ExyteMediaPicker

@MainActor
@Observable
public final class InputViewModel {

    var text = "" {
        didSet {
            validateDraft()
        }
    }
    var attachments = InputViewAttachments()
    var state: InputViewState = .empty

    var showGiphyPicker = false
    var showPicker = false
  
    var mediaPickerMode = MediaPickerMode.photos

    var showActivityIndicator = false
    
    var inputFieldId = UUID()
    
    @ObservationIgnored
    var recordingPlayer: RecordingPlayer?
    @ObservationIgnored
    var didSendMessage: ((DraftMessage) -> Void)?

    @ObservationIgnored
    private var recorder = Recorder()

    @ObservationIgnored
    private var saveEditingClosure: ((String) -> Void)?

    @ObservationIgnored
    private var recordPlayerSubscription: AnyCancellable?
    @ObservationIgnored
    private var subscriptions = Set<AnyCancellable>()
    
    public init(didSendMessage: ((DraftMessage) -> Void)? = nil) {
        self.didSendMessage = didSendMessage
    }
    
    func setRecorderSettings(recorderSettings: RecorderSettings = RecorderSettings()) {
        Task {
            await self.recorder.setRecorderSettings(recorderSettings)
        }
    }

    func onStart() {
        subscribeValidation()
        subscribePicker()
        subscribeGiphyPicker()
    }

    func onStop() {
        subscriptions.removeAll()
    }

    func reset() {
        showPicker = false
        showGiphyPicker = false
        text = ""
        saveEditingClosure = nil
        attachments = InputViewAttachments()
        subscribeValidation()
        state = .empty
        inputFieldId = UUID()
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
        case .giphy:
            showGiphyPicker = true
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
            Task {
                state = await recorder.isAllowedToRecordAudio ? .isRecordingTap : .waitingForRecordingPermission
                recordAudio()
            }
        case .recordAudioHold:
            Task {
                state = await recorder.isAllowedToRecordAudio ? .isRecordingHold : .waitingForRecordingPermission
                recordAudio()
            }
        case .recordAudioLock:
            state = .isRecordingTap
        case .stopRecordAudio:
            Task {
                await recorder.stopRecording()
                if let _ = attachments.recording {
                    state = .hasRecording
                }
                await recordingPlayer?.reset()
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
        Task {
            if await recorder.isRecording { return }
        }
        Task { @MainActor [recorder] in
            attachments.recording = Recording()
            let url = await recorder.startRecording { duration, samples in
                DispatchQueue.main.async { [weak self] in
                    self?.attachments.recording?.duration = duration
                    self?.attachments.recording?.waveformSamples = samples
                }
            }
            if state == .waitingForRecordingPermission {
                state = .isRecordingTap
            }
            attachments.recording?.url = url
        }
    }
}

private extension InputViewModel {

    func validateDraft() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
            guard state != .editing else { return } // special case
            if !self.text.isEmpty || !self.attachments.medias.isEmpty {
                self.state = .hasTextOrMedia
            } else if self.text.isEmpty,
                      self.attachments.medias.isEmpty,
                      self.attachments.recording == nil {
                self.state = .empty
            }
//        }
    }

    func subscribeValidation() {
//        $attachments.sink { [weak self] _ in
//            self?.validateDraft()
//        }
//        .store(in: &subscriptions)
//
//        $text.sink { [weak self] _ in
//            self?.validateDraft()
//        }
//        .store(in: &subscriptions)
    }

    func subscribeGiphyPicker() {
//        $showGiphyPicker
//            .sink { [weak self] value in
//                if !value {
//                  self?.attachments.giphyMedia = nil
//                }
//            }
//            .store(in: &subscriptions)
    }
  
    func subscribePicker() {
//        $showPicker
//            .sink { [weak self] value in
//                if !value {
//                    self?.attachments.medias = []
//                }
//            }
//            .store(in: &subscriptions)
    }

    func subscribeRecordPlayer() {
        Task { @MainActor in
            if let recordingPlayer {
                recordPlayerSubscription = recordingPlayer.didPlayTillEnd
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
            giphyMedia: attachments.giphyMedia,
            recording: attachments.recording,
            replyMessage: attachments.replyMessage,
            createdAt: Date()
        )
        didSendMessage?(draft)
        showActivityIndicator = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.reset()
        }
    }
}
