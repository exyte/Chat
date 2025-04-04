//
//  RecordingPlayer.swift
//
//
//  Created by Alexandra Afonasova on 21.06.2022.
//

@preconcurrency import Combine
@preconcurrency import AVFoundation

final actor RecordingPlayer: ObservableObject {

    @MainActor @Published var playing = false
    @MainActor @Published var duration: Double = 0.0
    @MainActor @Published var secondsLeft: Double = 0.0
    @MainActor @Published var progress: Double = 0.0

    @MainActor let didPlayTillEnd = PassthroughSubject<Void, Never>()

    private var recording: Recording? {
        didSet {
            internalPlaying = false
            Task { @MainActor in
                self.progress = 0
                if let r = await self.recording {
                    self.duration = r.duration
                    self.secondsLeft = r.duration
                } else {
                    self.duration = 0
                    self.secondsLeft = 0
                }
            }
        }
    }

    private var internalPlaying = false {
        didSet {
            Task { @MainActor in
                self.playing = await internalPlaying
            }
        }
    }

    private let audioSession = AVAudioSession()
    private var player: AVPlayer?
    private var timeObserver: Any?

    init() {
        try? audioSession.setCategory(.playback)
        try? audioSession.overrideOutputAudioPort(.speaker)
    }

    func play(_ recording: Recording) {
        setupPlayer(for: recording)
        play()
    }

    func pause() {
        player?.pause()
        internalPlaying = false
    }

    func togglePlay(_ recording: Recording) {
        if self.recording?.url != recording.url {
            setupPlayer(for: recording)
        }
        internalPlaying ? pause() : play()
    }

    func seek(with recording: Recording, to progress: Double) {
        let goalTime = recording.duration * progress
        if self.recording == nil {
            setupPlayer(for: recording)
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await player?.seek(to: CMTime(seconds: goalTime, preferredTimescale: 10))
                if !internalPlaying { play() }
            }
            return
        }
        player?.seek(to: CMTime(seconds: goalTime, preferredTimescale: 10))
        if !internalPlaying {
            play()
        }
    }

    func seek(to progress: Double) {
        if let recording {
            let goalTime = recording.duration * progress
            player?.seek(to: CMTime(seconds: goalTime, preferredTimescale: 10))
            if !internalPlaying { play() }
        }
    }

    func reset() {
        if internalPlaying { pause() }
        recording = nil
    }

    private func play() {
        try? audioSession.setActive(true)
        player?.play()
        internalPlaying = true
        NotificationCenter.default.post(name: .chatAudioIsPlaying, object: self)
    }

    private func setupPlayer(for recording: Recording) {
        guard let url = recording.url else { return }
        self.recording = recording

        NotificationCenter.default.removeObserver(self)
        timeObserver = nil
        player?.replaceCurrentItem(with: nil)

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(forName: .chatAudioIsPlaying, object: nil, queue: nil) { notification in
            if let sender = notification.object as? RecordingPlayer {
                Task { [weak self] in
                    if await sender.recording?.url == self?.recording?.url {
                        return
                    }
                    await self?.pause()
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { _ in
            Task { [weak self] in
                await self?.setPlayingState(false)
                await self?.player?.seek(to: .zero)
                await self?.didPlayTillEnd.send()
            }
        }

        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 10),
            queue: nil
        ) { time in
            Task { [weak self] in
                guard let self, let item = await self.player?.currentItem, !item.duration.seconds.isNaN else { return }
                await MainActor.run {
                     self.updateProgress(item.duration, time)
                }
            }
        }
    }

    private func setPlayingState(_ isPlaying: Bool) {
        self.internalPlaying = isPlaying
    }

    @MainActor
    private func updateProgress(_ itemDuration: CMTime, _ time: CMTime) {
        duration = itemDuration.seconds
        progress = time.seconds / itemDuration.seconds
        secondsLeft = (itemDuration - time).seconds.rounded()
    }
}
