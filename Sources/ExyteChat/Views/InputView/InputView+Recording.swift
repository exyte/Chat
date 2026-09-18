//
//  InputView+Recording.swift
//  Chat
//

import SwiftUI

private let tapDelay: Double = 0.2
private let stopRecordButtonOffset: CGFloat = 24

extension InputView {

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

                RecordWaveformPlaying(
                    samples: recording.waveformSamples,
                    progress: recordingPlayer.progress,
                    color: theme.colors.mainText,
                    addExtraDots: true
                ) { progress in
                    Task {
                        await recordingPlayer.seek(with: recording, to: progress)
                    }
                }
            }
            .padding(.horizontal, 8)
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

                if value.location.x < chatSize.width / 2,
                   value.location.y > recordButtonFrame.minY {
                    cancelGesture = true
                    onAction(.deleteRecord)
                }
            }
            .onEnded { value in
                if !cancelGesture {
                    tapDelayTimer = nil
                    if recordButtonFrame.contains(value.location) {
                        if let dragStart = dragStart, Date().timeIntervalSince(dragStart) < tapDelay {
                            onAction(.recordAudioTap)
                        } else if state != .waitingForRecordingPermission {
                            onAction(.send)
                        }
                    } else if lockRecordFrame.contains(value.location) {
                        onAction(.recordAudioLock)
                    } else if deleteRecordFrame.contains(value.location) {
                        onAction(.deleteRecord)
                    } else {
                        onAction(.send)
                    }
                }
                dragStart = nil
            }
    }
}
