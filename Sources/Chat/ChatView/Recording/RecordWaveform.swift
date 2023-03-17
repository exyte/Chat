//
//  RecordWaveform.swift
//  
//
//  Created by Alisa Mylnikova on 14.03.2023.
//

import SwiftUI

struct RecordWaveformWithButtons: View {

    @Environment(\.chatTheme) private var theme

    @ObservedObject var recordPlayer = RecordingPlayer.shared

    var recording: Recording

    var colorButton: Color
    var colorButtonBg: Color
    var colorWaveform: Color

    var time: Int {
        Int(recordPlayer.secondsLeft != 0 ? recordPlayer.secondsLeft : recording.duration)
    }

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if recordPlayer.playing {
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
                recordPlayer.togglePlay(recording)
            }
            
            VStack(alignment: .leading) {
                RecordWaveformPlaying(samples: recording.waveformSamples, progress: recordPlayer.progress, color: colorWaveform, addExtraDots: false)
                Text(DateFormatter.timeString(time))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundColor(colorWaveform)
            }
        }
    }
}

struct RecordWaveformPlaying: View {

    var samples: [CGFloat] // 0...1
    var progress: CGFloat
    var color: Color
    var addExtraDots: Bool

    var maxLength: CGFloat {
        (RecordWaveform.spacing + RecordWaveform.width) * CGFloat(samples.count)
    }

    var body: some View {
        ZStack {
            GeometryReader { g in
                let adjusted = adjustedSamples(g.size)
                RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                    .foregroundColor(color.opacity(0.4))
                RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                    .foregroundColor(color)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: maxLength * progress, height: g.size.height)
                    }
            }
            .fixedSize(horizontal: !addExtraDots, vertical: true)
        }
    }

    func adjustedSamples(_ size: CGSize) -> [CGFloat] {
        let maxSamples = Int(size.width / (RecordWaveform.width + RecordWaveform.spacing))

        var adjusted = samples
        var temp = [CGFloat]()
        while adjusted.count > maxSamples {
            var i = 0
            while i < adjusted.count {
                if i == adjusted.count - 1 {
                    temp.append(adjusted[i])
                    break
                }

                temp.append((adjusted[i] + adjusted[i+1])/2)
                i+=2
            }
            adjusted = temp
            temp = []
        }
        return adjusted
    }
}

struct RecordWaveform: View {

    var samples: [CGFloat] // 0...1
    var addExtraDots: Bool

    static let spacing: CGFloat = 2
    static let width: CGFloat = 2

    var body: some View {
        GeometryReader { g in
            HStack(alignment: .bottom, spacing: RecordWaveform.spacing) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, s in
                    Capsule()
                        .frame(width: RecordWaveform.width, height: 20 * CGFloat(s))
                }

                if addExtraDots {
                    ForEach(samples.count..<Int(g.size.width / (RecordWaveform.width + RecordWaveform.spacing)), id: \.self) { _ in
                        Capsule()
                            .viewSize(RecordWaveform.width)
                    }
                }
            }
        }
        .fixedSize(horizontal: !addExtraDots, vertical: true)
    }
}
