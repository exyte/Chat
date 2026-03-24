//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker

public enum InputViewStyle: Sendable {
    case message
    case signature
}

public enum InputViewAction: Sendable {
    case photo
    case add
    case camera
    case send

    case recordAudioHold
    case recordAudioTap
    case recordAudioLock
    case stopRecordAudio
    case deleteRecord
    case playRecord
    case pauseRecord
    //    case location
    //    case document

    case saveEdit
    case cancelEdit
}

public enum InputViewState: Sendable {
    case empty
    case hasTextOrMedia

    case waitingForRecordingPermission
    case isRecordingHold
    case hasRecording
    case playingRecording
    case pausedRecording

    case editing

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia, .hasRecording, .playingRecording, .pausedRecording: return true
        default: return false
        }
    }
}

public enum AvailableInputType: Sendable {
    case text
    case media
    case audio
}

public struct InputViewAttachments {
    var medias: [Media] = []
    var recording: Recording?
    var replyMessage: ReplyMessage?
}

struct InputView: View {
    
    @Environment(\.chatTheme) private var theme
    @Environment(\.mediaPickerTheme) private var pickerTheme

    @EnvironmentObject private var keyboardState: KeyboardState
    
    @ObservedObject var viewModel: InputViewModel
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var messageStyler: (String) -> AttributedString
    var recorderSettings: RecorderSettings = RecorderSettings()
    var localization: ChatLocalization
    
    @StateObject var recordingPlayer = RecordingPlayer()
    
    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }
    
    private var state: InputViewState {
        viewModel.state
    }
    
    @State private var isRecordingGestureActive = false
    @State private var hasStartedRecordingFromGesture = false
    @State private var startRecordingWorkItem: DispatchWorkItem?
    @State private var shouldCancelRecording = false
    private let cancelTranslationThreshold: CGFloat = 60
    private let holdStartDelay: DispatchTimeInterval = .milliseconds(200)
    
    var body: some View {
        VStack {
            viewOnTop
            HStack(alignment: .bottom, spacing: 10) {
                HStack(alignment: .bottom, spacing: 0) {
                    leftView
                    middleView
                    rightView
                }
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(style == .message ? theme.colors.inputBG : theme.colors.inputSignatureBG)
                }
                
                rightOutsideButton
            }
            .padding(.horizontal, MessageView.horizontalScreenEdgePadding)
            .padding(.vertical, 8)
        }
        .background(backgroundColor)
        .onAppear {
            viewModel.recordingPlayer = recordingPlayer
            viewModel.setRecorderSettings(recorderSettings: recorderSettings)
        }
        .onDrag(towards: .bottom, ofAmount: 100...) {
            keyboardState.resignFirstResponder()
        }
    }
    
    @ViewBuilder
    var leftView: some View {
        if [.isRecordingHold, .hasRecording, .playingRecording, .pausedRecording].contains(state) {
            deleteRecordButton
        } else {
            switch style {
            case .message:
                if isMediaAvailable() {
                    attachButton
                }
            case .signature:
                if viewModel.mediaPickerMode == .cameraSelection {
                    addButton
                } else {
                    Color.clear.frame(width: 12, height: 1)
                }
            }
        }
    }
    
    
    
    @ViewBuilder
    var middleView: some View {
        Group {
            switch state {
            case .hasRecording, .playingRecording, .pausedRecording:
                recordWaveform
            case .isRecordingHold:
                swipeToCancel
            default:
                TextInputView(
                    text: $viewModel.text,
                    inputFieldId: inputFieldId,
                    style: style,
                    availableInputs: availableInputs,
                    localization: localization
                )
            }
        }
        .frame(minHeight: 48)
    }
    
    @ViewBuilder
    var rightView: some View {
        Group {
            switch state {
            case .empty, .waitingForRecordingPermission:
                if case .message = style, isMediaAvailable() {
                    cameraButton
                }
            case .isRecordingHold:
                recordDurationInProcess
            case .hasRecording:
                recordDuration
            case .playingRecording, .pausedRecording:
                recordDurationLeft
            default:
                Color.clear.frame(width: 8, height: 1)
            }
        }
        .frame(minHeight: 48)
    }
    
    @ViewBuilder
    var editingButtons: some View {
        HStack {
            Button {
                onAction(.cancelEdit)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.red))
            }
            
            Button {
                onAction(.saveEdit)
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.green))
            }
        }
    }
    
    @ViewBuilder
    var rightOutsideButton: some View {
        if state == .editing {
            editingButtons
                .frame(height: 48)
        } else {
            Group {
                if state.canSend || !isAudioAvailable() {
                    sendButton
                        .disabled(!state.canSend)
                } else {
                    recordButton
                        .simultaneousGesture(dragGesture())
                        .onTapGesture {
                            onAction(.recordAudioTap)
                        }
                }
            }
            .viewSize(48)
        }
    }
    
    @ViewBuilder
    var viewOnTop: some View {
        if let message = viewModel.attachments.replyMessage {
            VStack(spacing: 8) {
                Rectangle()
                    .foregroundColor(theme.colors.messageFriendBG)
                    .frame(height: 2)
                
                HStack {
                    theme.images.reply.replyToMessage
                    Capsule()
                        .foregroundColor(theme.colors.messageMyBG)
                        .frame(width: 2)
                    VStack(alignment: .leading) {
                        Text(localization.replyToText + " " + message.user.name)
                            .font(.caption2)
                            .foregroundColor(theme.colors.mainCaptionText)
                        if !message.text.isEmpty {
                            textView(message.text)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundColor(theme.colors.mainText)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    Spacer()
                    
                    if let first = message.attachments.first {
                        AsyncImageView(attachment: first, size: CGSize(width: 30, height: 30))
                            .viewSize(30)
                            .cornerRadius(4)
                            .padding(.trailing, 16)
                    }
                    
                    if let _ = message.recording {
                        theme.images.inputView.microphone
                            .renderingMode(.template)
                            .foregroundColor(theme.colors.mainTint)
                    }
                    
                    theme.images.reply.cancelReply
                        .onTapGesture {
                            viewModel.attachments.replyMessage = nil
                        }
                }
                .padding(.horizontal, 26)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    func textView(_ text: String) -> some View {
        Text(text.styled(using: messageStyler))
    }
    
    var attachButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.inputView.attach
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
        }
    }
    
    var addButton: some View {
        Button {
            onAction(.add)
        } label: {
            theme.images.inputView.add
                .viewSize(24)
                .circleBackground(theme.colors.sendButtonBackground)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
    }
    
    var cameraButton: some View {
        Button {
            onAction(.camera)
        } label: {
            theme.images.inputView.attachCamera
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
        }
    }
    
    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(48)
                .circleBackground(theme.colors.sendButtonBackground)
        }
    }
    
    var recordButton: some View {
        theme.images.inputView.microphone
            .viewSize(48)
            .circleBackground(state == .isRecordingHold ? theme.colors.recordDot : theme.colors.sendButtonBackground)
            .scaleEffect(isRecordingGestureActive ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isRecordingGestureActive)
    }
    
    var deleteRecordButton: some View {
        Button {
            onAction(.deleteRecord)
        } label: {
            theme.images.recordAudio.deleteRecord
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
    }
    
    var swipeToCancel: some View {
        HStack {
            Spacer()
            HStack(spacing: 6) {
                theme.images.recordAudio.cancelRecord
                    .renderingMode(.template)
                Text(localization.cancelButtonText)
                    .font(.footnote)
            }
            .foregroundStyle(shouldCancelRecording ? theme.colors.recordDot : theme.colors.mainText)
            Spacer()
        }
    }
    
    var recordDurationInProcess: some View {
        HStack {
            Circle()
                .foregroundColor(theme.colors.recordDot)
                .viewSize(6)
            recordDuration
        }
    }
    
    var recordDuration: some View {
        Text(DateFormatter.timeString(Int(viewModel.attachments.recording?.duration ?? 0)))
            .foregroundColor(theme.colors.mainText)
            .opacity(0.6)
            .font(.caption2)
            .monospacedDigit()
            .padding(.trailing, 12)
    }
    
    var recordDurationLeft: some View {
        Text(DateFormatter.timeString(Int(recordingPlayer.secondsLeft)))
            .foregroundColor(theme.colors.mainText)
            .opacity(0.6)
            .font(.caption2)
            .monospacedDigit()
            .padding(.trailing, 12)
    }
    
    var playRecordButton: some View {
        Button {
            onAction(.playRecord)
        } label: {
            theme.images.recordAudio.playRecord
        }
    }
    
    var pauseRecordButton: some View {
        Button {
            onAction(.pauseRecord)
        } label: {
            theme.images.recordAudio.pauseRecord
        }
    }
    
    @ViewBuilder
    var recordWaveform: some View {
        if let recording = viewModel.attachments.recording {
            HStack(spacing: 8) {
                Group {
                    if state == .hasRecording || state == .pausedRecording {
                        playRecordButton
                    } else if state == .playingRecording {
                        pauseRecordButton
                    }
                }
                .frame(width: 20)
                
                RecordWaveformPlaying(samples: recording.waveformSamples, progress: recordingPlayer.progress, color: theme.colors.mainText, addExtraDots: true) { progress in
                    Task {
                        await recordingPlayer.seek(with: recording, to: progress)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    var backgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.mainBG
        case .signature:
            return pickerTheme.main.pickerBackground
        }
    }

    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
            .onChanged { value in
                if !isRecordingGestureActive {
                    isRecordingGestureActive = true
                    hasStartedRecordingFromGesture = false
                    withAnimation(.easeInOut(duration: 0.1)) {
                        shouldCancelRecording = false
                    }

                    let workItem = DispatchWorkItem {
                        hasStartedRecordingFromGesture = true
                        onAction(.recordAudioHold)
                    }

                    startRecordingWorkItem?.cancel()
                    startRecordingWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + holdStartDelay, execute: workItem)
                }

                if hasStartedRecordingFromGesture {
                    let isCancelling = value.translation.width < -cancelTranslationThreshold
                    if shouldCancelRecording != isCancelling {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            shouldCancelRecording = isCancelling
                        }
                    }
                }
            }
            .onEnded { _ in
                guard isRecordingGestureActive else { return }

                startRecordingWorkItem?.cancel()
                startRecordingWorkItem = nil

                if hasStartedRecordingFromGesture {
                    if shouldCancelRecording {
                        onAction(.deleteRecord)
                    } else if viewModel.attachments.recording != nil {
                        onAction(.send)
                    }
                }

                isRecordingGestureActive = false
                hasStartedRecordingFromGesture = false
                withAnimation(.easeInOut(duration: 0.1)) {
                    shouldCancelRecording = false
                }
            }
    }
    
    private func isAudioAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.audio)
    }
    
    private func isMediaAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.media)
    }
}

@MainActor
func performBatchTableUpdates(_ tableView: UITableView, closure: ()->()) async {
    await withCheckedContinuation { continuation in
        tableView.performBatchUpdates {
            closure()
        } completion: { _ in
            continuation.resume()
        }
    }
}
