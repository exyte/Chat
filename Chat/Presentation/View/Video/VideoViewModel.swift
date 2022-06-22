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

final class VideoViewModel: ObservableObject {
    @Published var attachment: VideoAttachment
    @Published var player: AVPlayer?

    @Published var isPlaying = false
    @Published var hideAction = false

    // TODO: Create and handle flag `var shouldDownloadBeforePlay = false`
    // Use environment values to propagate this behavior

//    var localUrl: URL {
//        getDocumentsDirectory()
//            .appending(path: attachment.full.lastPathComponent)
//    }

    var subscriptions = Set<AnyCancellable>()
    var timersSubscriptions = Set<AnyCancellable>()

    init(attachment: VideoAttachment) {
        self.attachment = attachment
    }

    // TODO: Download video to local file before create player
    func onStart() {
        self.player = AVPlayer(url: attachment.full)
//        if (try? localUrl.checkResourceIsReachable()) == true {
//            print("[VideoViewModel]", "file already exist at url:", localUrl)
//            self.player = AVPlayer(url: localUrl)
//        } else {
//            print("[VideoViewModel]", "start save file at url:", localUrl)
//            loadVideo()
//        }
    }

    func togglePlay() {
        if player?.isPlaying == true {
            player?.pause()
            timersSubscriptions.removeAll()
        } else {
            player?.play()
            hideActionsAfterDelay()
        }
        self.isPlaying = player?.isPlaying ?? false
    }

    func showActions() {
        hideAction = false
        if player?.isPlaying == true {
            hideActionsAfterDelay()
        }
    }

    private func hideActionsAfterDelay() {
        timersSubscriptions.removeAll()
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                self?.hideAction = true
            }
            .store(in: &timersSubscriptions)
    }
//    func getDocumentsDirectory() -> URL {
//        guard let url = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        else { fatalError() }
//        return url
//    }
}

//private extension VideoViewModel {
//    func loadVideo() {
//        URLSession.shared
//            .dataTaskPublisher(for: attachment.full)
//            .receive(on: DispatchQueue.global())
//            .map { $0.data }
//            .tryMap { [localUrl] data in
//                try data.write(to: localUrl)
//            }
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print(completion)
//            } receiveValue: { [weak self, localUrl] value in
//                print(value)
//                print("[VideoViewModel]", "file saved at url:", localUrl)
//                self?.player = AVPlayer(url: localUrl)
//            }
//            .store(in: &subscriptions)
//    }
//}
