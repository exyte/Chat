//
//  Created by Alex.M on 21.06.2022.
//

import Foundation
import Combine
import AVKit

// TODO: Create option "download video before playing"
final class VideoViewModel: ObservableObject {

    @Published var attachment: VideoAttachment
    @Published var player: AVPlayer?

    @Published var isPlaying = false
    @Published var isMuted = false

    init(attachment: VideoAttachment) {
        self.attachment = attachment
    }

    func onStart() {
        if player == nil {
            self.player = AVPlayer(url: attachment.full)

            NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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

    func toggleMute() {
        player?.isMuted.toggle()
        isMuted = player?.isMuted ?? false
    }
}

private extension VideoViewModel {

    func playVideo() {
        player?.play()
        isPlaying = player?.isPlaying ?? false
    }

    @objc func finishVideo() {
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 10))
        isPlaying = false
    }

    func pauseVideo() {
        player?.pause()
        isPlaying = player?.isPlaying ?? false
    }
}
