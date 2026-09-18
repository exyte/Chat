//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker
import AnchoredPopup

struct InputView: View {

    @Environment(\.chatTheme) var theme
    @Environment(\.mediaPickerTheme) var pickerTheme
    @Environment(\.chatSize) var chatSize

    @EnvironmentObject var keyboardState: KeyboardState

    @ObservedObject var viewModel: InputViewModel
    @StateObject var recordingPlayer = RecordingPlayer()

    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var recorderSettings: RecorderSettings = RecorderSettings()
    var audioRecordingMode: AudioRecordingMode = .holdToRecord
    var photoPickerBackend: PhotoPickerBackend = .custom
    var localization: ChatLocalization

    @State var stopRecordButtonSize: CGSize = .zero
    @State var lockRecordButtonSize: CGSize = .zero

    @State var recordButtonFrame: CGRect = .zero
    @State var lockRecordFrame: CGRect = .zero
    @State var deleteRecordFrame: CGRect = .zero
    @State var inputBarFrame: CGRect = .zero

    @State var dragStart: Date?
    @State var tapDelayTimer: Timer?
    @State var cancelGesture = false

    var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }

    var state: InputViewState {
        viewModel.state
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
            .padding(MessageView.horizontalScreenEdgePadding, 8)
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

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(48)
                .circleBackground(theme.colors.sendButtonBackground)
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

    var backgroundColor: Color {
        switch style {
        case .message:
            return theme.contentBG
        case .signature:
            return pickerTheme.main.pickerBackground
        }
    }

    func isAudioAvailable() -> Bool {
        availableInputs.contains(AvailableInputType.audio)
    }

    func isGiphyAvailable() -> Bool {
        availableInputs.contains(AvailableInputType.giphy)
    }

    func isMediaAvailable() -> Bool {
        availableInputs.contains(AvailableInputType.media)
    }

    func isDocumentAvailable() -> Bool {
        availableInputs.contains(AvailableInputType.document)
    }

    func isLocationAvailable() -> Bool {
        availableInputs.contains(AvailableInputType.location)
    }
}
