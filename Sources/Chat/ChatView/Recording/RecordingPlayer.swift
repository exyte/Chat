//
//  RecordingPlayer.swift
//
//
//  Created by Alexandra Afonasova on 21.06.2022.
//

import Combine
import AVFoundation

final class RecordingPlayer: ObservableObject {

    @Published var playing = false
    @Published var duration: Double = 0.0
    @Published var secondsLeft: Double = 0.0
    @Published var progress: Double = 0.0

    var didPlayTillEnd = PassthroughSubject<Void, Never>()

    private var recording: Recording?

    private var player: AVPlayer?
    private var timeObserver: Any?

    func play(_ recording: Recording) {
        self.recording = recording
        if let url = recording.url {
            setupPlayer(for: url, trackDuration: recording.duration)
            play()
        }
    }

    func pause() {
        player?.pause()
        playing = false
    }

    func togglePlay(_ recording: Recording) {
        if self.recording?.url != recording.url {
            self.recording = recording
            if let url = recording.url {
                setupPlayer(for: url, trackDuration: recording.duration)
            }
        }
        if playing { pause() }
        else { play() }
    }

    func seek(to progress: Double) {
        let goalTime = duration * progress
        player?.seek(to: CMTime(seconds: goalTime, preferredTimescale: 10))
        if !playing { play() }
    }

    private func play() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
        playing = true
    }

    private func setupPlayer(for url: URL, trackDuration: Double) {
        duration = trackDuration
        progress = 0.0
        secondsLeft = trackDuration
        NotificationCenter.default.removeObserver(self)
        timeObserver = nil
        player?.replaceCurrentItem(with: nil)

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            self?.playing = false
            self?.player?.seek(to: .zero)
            self?.didPlayTillEnd.send()
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 10),
            queue: DispatchQueue.main
        ) { [weak self] time in
            guard let item = self?.player?.currentItem, !item.duration.seconds.isNaN else { return }
            self?.duration = item.duration.seconds
            self?.progress = time.seconds / item.duration.seconds
            self?.secondsLeft = (item.duration - time).seconds.rounded()
        }
    }

}
