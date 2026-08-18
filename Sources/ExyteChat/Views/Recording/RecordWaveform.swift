//
//  RecordWaveform.swift
//  
//
//  Created by Alisa Mylnikova on 14.03.2023.
//

import SwiftUI

struct RecordWaveformWithButtons: View {

    @Environment(\.chatTheme) private var theme

    @ObservedObject var recordPlayer: RecordingPlayer

    // 160 is screen left-padding/right-padding and playButton's width.
    // ensure that the view does not exceed the screen, need to subtract
    // TODO: do not hardcode this value
    static let viewPadding: CGFloat = 160

    var recording: Recording

    var colorButton: Color
    var colorButtonBg: Color
    var colorWaveform: Color

    var isPlaying: Bool {
        recordPlayer.playing && recordPlayer.currentURL == recording.url
    }

    var duration: Int {
        let secondsLeft = isPlaying ? recordPlayer.secondsLeft : 0
        return max(Int((secondsLeft != 0 ? secondsLeft : recording.duration) - 0.5), 0)
    }

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if isPlaying {
                    theme.images.message.pauseAudio
                        .renderingMode(.template)
                } else {
                    theme.images.message.playAudio
                        .renderingMode(.template)
                }
            }
            .foregroundColor(colorButton)
            .viewSize(40)
            .circleBackground(colorButtonBg)
            .onTapGesture {
                Task {
                    await recordPlayer.togglePlay(recording)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                RecordWaveformPlaying(samples: recording.waveformSamples, progress: isPlaying ? recordPlayer.progress : 0, color: colorWaveform, addExtraDots: false) { progress in
                    Task {
                        await recordPlayer.seek(with: recording, to: progress)
                    }
                }
                Text(DateFormatter.timeString(duration))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundColor(colorWaveform)
            }
        }
    }
}

struct RecordWaveformPlaying: View {
    @Environment(\.chatSize) private var chatSize

    var samples: [CGFloat] // 0...1
    var progress: CGFloat
    var color: Color
    var addExtraDots: Bool

    let progressChangeHandler: (CGFloat) -> Void

    @State private var offset: CGSize = .zero
    @State private var recordingMaxLen: CGFloat = 0

    var body: some View {
        if addExtraDots {
            GeometryReader { g in
                let adjusted = adjustedSamples(g.size.width)
                let maxLen = computeMaxLength(adjusted)
                waveformZStack(adjusted: adjusted, maxLen: maxLen)
                    .onAppear { recordingMaxLen = maxLen }
                    .onChange(of: g.size.width) { _, newWidth in
                        let adj = adjustedSamples(newWidth)
                        recordingMaxLen = computeMaxLength(adj)
                    }
            }
            .frame(height: RecordWaveform.maxSampleHeight)
            .frame(maxWidth: .infinity)
            .gesture(dragGesture(maxLen: recordingMaxLen))
        } else {
            let adjusted = adjustedSamples(chatSize.width)
            let maxLen = computeMaxLength(adjusted)
            waveformZStack(adjusted: adjusted, maxLen: maxLen)
                .frame(height: RecordWaveform.maxSampleHeight)
                .frame(width: maxLen)
                .fixedSize(horizontal: true, vertical: true)
                .gesture(dragGesture(maxLen: maxLen))
        }
    }

    @ViewBuilder
    private func waveformZStack(adjusted: [CGFloat], maxLen: CGFloat) -> some View {
        ZStack {
            RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                .foregroundColor(color.opacity(0.4))
            RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                .foregroundColor(color)
                .mask(alignment: .leading) {
                    Rectangle()
                        .frame(width: maxLen * progress, height: 2 * RecordWaveform.maxSampleHeight)
                }
        }
        .frame(height: RecordWaveform.maxSampleHeight)
    }

    private func dragGesture(maxLen: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in offset = value.translation }
            .onEnded { _ in
                guard maxLen > 0 else { return }
                let current = maxLen * progress
                // multiply by 0.5 so that the sliding will not be too sensitive
                var newPos = current + offset.width * 0.5
                newPos = offset.width > 0 ? min(newPos, maxLen) : max(newPos, 0)
                progressChangeHandler(newPos / maxLen)
            }
    }

    private func computeMaxLength(_ adjusted: [CGFloat]) -> CGFloat {
        max((RecordWaveform.spacing + RecordWaveform.width) * CGFloat(adjusted.count) - RecordWaveform.spacing, 0)
    }

    func adjustedSamples(_ maxWidth: CGFloat) -> [CGFloat] {
        // Don't set maxSamples as Int, as casting to Int can make it zero, and we divide by it later.
        let maxSamples = (maxWidth - RecordWaveformWithButtons.viewPadding) / (RecordWaveform.width + RecordWaveform.spacing)
        guard maxSamples > 0, Double(samples.count) > maxSamples else { return samples }
        // use ceil to ensure that the adjusted.count will not be greater than maxSamples
        let ratio = Int(ceil(Double(samples.count) / maxSamples))
        return stride(from: 0, to: samples.count, by: ratio).map { samples[$0] }
    }
}

struct RecordWaveform: View {

    var samples: [CGFloat] // 0...1
    var addExtraDots: Bool

    static let spacing: CGFloat = 2
    static let width: CGFloat = 2
    static let maxSampleHeight: CGFloat = 20

    var body: some View {
        GeometryReader { g in
            HStack(alignment: .bottom, spacing: RecordWaveform.spacing) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, s in
                    Capsule()
                        .frame(width: RecordWaveform.width, height: RecordWaveform.maxSampleHeight * CGFloat(s))
                }
                let maxSampleCounts = Int((g.size.width) / (RecordWaveform.width + RecordWaveform.spacing))
                if addExtraDots && samples.count < maxSampleCounts {
                    ForEach(samples.count..<maxSampleCounts, id: \.self) { _ in
                        Capsule()
                            .viewSize(RecordWaveform.width)
                    }
                }
            }
            .frame(height: RecordWaveform.maxSampleHeight)
        }
        .frame(height: RecordWaveform.maxSampleHeight)
        .fixedSize(horizontal: !addExtraDots, vertical: true)
    }
}
