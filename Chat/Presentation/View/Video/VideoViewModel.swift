//
//  Created by Alex.M on 21.06.2022.
//

import Foundation
import Combine
import AVKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

// TODO: Create option "download video before playing"
final class VideoViewModel: ObservableObject {
    @Published var attachment: VideoAttachment
    @Published var player: AVPlayer?

    @Published var isPlaying = false
    @Published var hideAction = false

    var subscriptions = Set<AnyCancellable>()
    var timersSubscriptions = Set<AnyCancellable>()

    init(attachment: VideoAttachment) {
        self.attachment = attachment
    }

    func onStart() {
        if player == nil {
            self.player = AVPlayer(url: attachment.full)
        }
    }

    func onStop() {
        pauseVideo()
    }

    func togglePlay() {
        if player?.isPlaying == true {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    func showActions() {
        hideAction = false
        if player?.isPlaying == true {
            hideActionsAfterDelay()
        }
    }
}

private extension VideoViewModel {
    func playVideo() {
        player?.play()
        hideActionsAfterDelay()
        isPlaying = player?.isPlaying ?? false
    }

    func pauseVideo() {
        player?.pause()
        timersSubscriptions.removeAll()
        hideAction = false
        isPlaying = player?.isPlaying ?? false
    }

    func hideActionsAfterDelay() {
        timersSubscriptions.removeAll()
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.hideAction = true
            }
            .store(in: &timersSubscriptions)
    }
}
