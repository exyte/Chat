//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker
import GiphyUISDK
import AnchoredPopup

public enum InputViewStyle: Sendable {
    case message
    case signature
}

public enum AudioRecordingMode: Sendable {
    /// Default: hold the mic button to record; slide up to lock into hands-free mode.
    case holdToRecord
    /// Tap the mic button once to start recording, tap the stop button to finish. No lock capsule.
    case tapToToggle
}

public enum InputViewAction: Sendable {
    case giphy
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
    case isRecordingTap
    case hasRecording
    case playingRecording
    case pausedRecording

    case editing

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia, .hasRecording, .isRecordingTap, .playingRecording, .pausedRecording: return true
        default: return false
        }
    }
}

public enum AvailableInputType: Sendable {
    case text
    case media
    case audio
    case giphy
}

public struct InputViewAttachments {
    var medias: [Media] = []
    var recording: Recording?
    var giphyMedia: GPHMedia?
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
    var recorderSettings: RecorderSettings = RecorderSettings()
    var audioRecordingMode: AudioRecordingMode = .holdToRecord
    var photoPickerBackend: PhotoPickerBackend = .custom
    var localization: ChatLocalization

    @StateObject var recordingPlayer = RecordingPlayer()
    
    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }
    
    private var state: InputViewState {
        viewModel.state
    }

    @State private var stopRecordButtonSize: CGSize = .zero
    @State private var lockRecordButtonSize: CGSize = .zero
    
    @State private var recordButtonFrame: CGRect = .zero
    @State private var lockRecordFrame: CGRect = .zero
    @State private var deleteRecordFrame: CGRect = .zero
    @State private var inputBarFrame: CGRect = .zero

    @State private var dragStart: Date?
    @State private var tapDelayTimer: Timer?
    @State private var cancelGesture = false
    private let tapDelay = 0.2
    private let stopRecordButtonOffset: CGFloat = 24
    private let attachMenuLeftMargin: CGFloat = 14
    private let attachMenuGap: CGFloat = 16

    private struct AttachMenuItem {
        let icon: Image
        let title: String
        let action: InputViewAction
    }

    var body: some View {
        VStack {
            viewOnTop
                .padding(.top, 6)
                .transition(.move(edge: .bottom))

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
                .frameGetter($inputBarFrame)

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
        if [.isRecordingTap, .isRecordingHold, .hasRecording, .playingRecording, .pausedRecording].contains(state) {
            deleteRecordButton
        } else {
            switch style {
            case .message:
                leftButton
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
            case .isRecordingTap:
                recordingInProgress
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
            case .hasTextOrMedia:
                if case .message = style, !viewModel.text.isEmpty {
                    clearTextButton
                }
            case .isRecordingHold, .isRecordingTap:
                recordDurationInProcess
            case .hasRecording:
                recordDuration
            case .playingRecording, .pausedRecording:
                recordDurationLeft
            default:
                EmptyView()
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
        } else if audioRecordingMode == .tapToToggle {
            tapToToggleButton
        } else {
            holdToRecordButton
        }
    }

    var holdToRecordButton: some View {
        ZStack {
            if [.isRecordingTap, .isRecordingHold].contains(state) {
                RecordIndicator()
                    .viewSize(80)
                    .foregroundColor(theme.colors.sendButtonBackground)
            }
            Group {
                if state.canSend || !isAudioAvailable() {
                    sendButton
                        .disabled(!state.canSend)
                } else {
                    recordButton
                        .highPriorityGesture(dragGesture())
                }
            }
            .compositingGroup()
            .overlay(alignment: .top) {
                if state == .isRecordingTap {
                    stopRecordButton
                        .sizeGetter($stopRecordButtonSize)
                        .offset(y: -stopRecordButtonSize.height - stopRecordButtonOffset)
                } else if state == .isRecordingHold {
                    lockRecordButton
                        .sizeGetter($lockRecordButtonSize)
                        .offset(y: -lockRecordButtonSize.height - stopRecordButtonOffset)
                }
            }
        }
        .viewSize(48)
    }

    var tapToToggleButton: some View {
        ZStack {
            if state == .isRecordingTap {
                RecordIndicator()
                    .viewSize(80)
                    .foregroundColor(theme.colors.sendButtonBackground)
            }
            if state == .isRecordingTap {
                stopRecordButton
            } else if state.canSend || !isAudioAvailable() {
                sendButton
                    .disabled(!state.canSend)
            } else {
                recordButton
                    .onTapGesture {
                        onAction(.recordAudioTap)
                    }
            }
        }
        .viewSize(48)
    }
    
    @ViewBuilder
    var viewOnTop: some View {
        if style == .message, photoPickerBackend == .system, !viewModel.attachments.medias.isEmpty {
            mediaAttachmentsPreview
        }
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
                        if !message.attributedText.characters.isEmpty {
                            Text(message.attributedText)
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
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.attachments.replyMessage = nil
                            }
                        }
                }
                .padding(.horizontal, 26)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    var mediaAttachmentsPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.attachments.medias) { media in
                    MediaAttachmentThumbnail(media: media) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.attachments.medias.removeAll { $0.id == media.id }
                        }
                    }
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 26)
        }
    }

    private var attachMenuItems: [AttachMenuItem] {
        var items: [AttachMenuItem] = []
        if isMediaAvailable() {
            items.append(AttachMenuItem(icon: theme.images.inputView.attach, title: localization.attachMediaText, action: .photo))
            if photoPickerBackend == .system {
                items.append(AttachMenuItem(icon: theme.images.inputView.attachCamera, title: localization.attachCameraText, action: .camera))
            }
        }
        if isGiphyAvailable() {
            items.append(AttachMenuItem(icon: theme.images.inputView.sticker, title: localization.attachGifText, action: .giphy))
        }
        return items
    }

    @ViewBuilder
    var leftButton: some View {
        let items = attachMenuItems

        if items.count > 1 {
            attachMenuButton(items: items)
        } else if let item = items.first, item.action == .photo {
            mediaButton
        } else if let item = items.first, item.action == .giphy {
            giphyButton
        }
    }

    private var attachMenuPopupId: String {
        "exyte-chat-attach-menu-\(inputFieldId)"
    }

    private func attachMenuContent(_ items: [AttachMenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                AttachMenuRow(icon: item.icon, title: item.title) {
                    onAction(item.action)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.colors.inputBG)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }

    private func attachMenuButton(items: [AttachMenuItem]) -> some View {
        theme.images.inputView.attach
            .viewSize(24)
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
            .useAsPopupAnchor(id: attachMenuPopupId) {
                attachMenuContent(items)
            } customize: {
                $0.position(.absolute(.bottomLeading, position: CGPoint(x: attachMenuLeftMargin, y: inputBarFrame.minY - attachMenuGap)))
                    .background(.none)
                    .closeOnTapOutside(true)
                    .animation(.default)
            }
    }

    var mediaButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.inputView.attach
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
        }
    }

    var giphyButton: some View {
        Button {
            onAction(.giphy)
        } label: {
            theme.images.inputView.sticker
                .resizable()
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
        }
    }

    var clearTextButton: some View {
        Button {
            viewModel.text = ""
        } label: {
            theme.images.inputView.clearText
                .resizable()
                .renderingMode(.template)
                .foregroundColor(theme.colors.mainText.opacity(0.6))
                .viewSize(18)
                .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
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
            .circleBackground(theme.colors.sendButtonBackground)
            .frameGetter($recordButtonFrame)
    }
    
    var deleteRecordButton: some View {
        Button {
            onAction(.deleteRecord)
        } label: {
            theme.images.recordAudio.deleteRecord
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
        .frameGetter($deleteRecordFrame)
    }
    
    var stopRecordButton: some View {
        Button {
            onAction(.stopRecordAudio)
        } label: {
            theme.images.recordAudio.stopRecord
                .viewSize(28)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                )
        }
    }
    
    var lockRecordButton: some View {
        Button {
            onAction(.recordAudioLock)
        } label: {
            VStack(spacing: 20) {
                theme.images.recordAudio.lockRecord
                theme.images.recordAudio.sendRecord
            }
            .frame(width: 28)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: 1)
            )
        }
        .frameGetter($lockRecordFrame)
    }
    
    var swipeToCancel: some View {
        HStack {
            Spacer()
            Button {
                onAction(.deleteRecord)
            } label: {
                HStack {
                    theme.images.recordAudio.cancelRecord
                        .renderingMode(.template)
                        .foregroundStyle(theme.colors.mainText)
                    Text(localization.cancelButtonText)
                        .font(.footnote)
                        .foregroundColor(theme.colors.mainText)
                }
            }
            Spacer()
        }
    }
    
    var recordingInProgress: some View {
        HStack {
            Spacer()
            Text(localization.recordingText)
                .font(.footnote)
                .foregroundColor(theme.colors.mainText)
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
            return theme.contentBG
        case .signature:
            return pickerTheme.main.pickerBackground
        }
    }

    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
            .onChanged { [state] value in
                if dragStart == nil {
                    dragStart = Date()
                    cancelGesture = false
                    tapDelayTimer = Timer.scheduledTimer(withTimeInterval: tapDelay, repeats: false) { _ in
                        if state != .isRecordingTap, state != .waitingForRecordingPermission {
                            DispatchQueue.main.async {
                                self.onAction(.recordAudioHold)
                            }
                        }
                    }
                }
                
                if value.location.y < lockRecordFrame.minY,
                   value.location.x > recordButtonFrame.minX {
                    cancelGesture = true
                    onAction(.recordAudioLock)
                }
                
                if value.location.x < UIScreen.main.bounds.width/2,
                   value.location.y > recordButtonFrame.minY {
                    cancelGesture = true
                    onAction(.deleteRecord)
                }
            }
            .onEnded() { value in
                if !cancelGesture {
                    tapDelayTimer = nil
                    if recordButtonFrame.contains(value.location) {
                        if let dragStart = dragStart, Date().timeIntervalSince(dragStart) < tapDelay {
                            onAction(.recordAudioTap)
                        } else if state != .waitingForRecordingPermission {
                            onAction(.send)
                        }
                    }
                    else if lockRecordFrame.contains(value.location) {
                        onAction(.recordAudioLock)
                    }
                    else if deleteRecordFrame.contains(value.location) {
                        onAction(.deleteRecord)
                    } else {
                        onAction(.send)
                    }
                }
                dragStart = nil
            }
    }
    
    private func isAudioAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.audio)
    }
    
    private func isGiphyAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.giphy)
    }
    
    private func isMediaAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.media)
    }
}

private struct AttachMenuRow: View {
    @Environment(\.chatTheme) private var theme
    @Environment(\.anchoredPopupDismiss) private var dismissPopup

    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
            dismissPopup?()
        } label: {
            HStack(spacing: 10) {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(theme.colors.mainTint)
                Text(title)
                    .font(.callout)
                    .foregroundColor(theme.colors.mainText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct MediaAttachmentThumbnail: View {
    @Environment(\.chatTheme) private var theme

    let media: Media
    let onRemove: () -> Void

    @State private var thumbnail: UIImage?

    private var thumbnailSize: CGFloat {
        UIScreen.main.bounds.width / 5
    }

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(theme.colors.messageFriendBG)
            }
            if media.type == .video {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            Button(action: onRemove) {
                theme.images.mediaPicker.cross
                    .resizable()
                    .frame(width: 10, height: 10)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .foregroundColor(.white)
            }
            .offset(x: 6, y: -6)
        }
        .task(id: media.id) {
            if let data = await media.getThumbnailData(), let image = UIImage(data: data) {
                thumbnail = image
            }
        }
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
