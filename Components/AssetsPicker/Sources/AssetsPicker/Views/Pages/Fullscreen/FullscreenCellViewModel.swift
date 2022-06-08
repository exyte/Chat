//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import AVKit
import UIKit.UIImage

final class FullscreenCellViewModel: ObservableObject {
    let media: MediaModel
    
    @Published var preview: UIImage? = nil
    @Published var player: AVPlayer? = nil
    var subscriptions = Set<AnyCancellable>()
    
    init(media: MediaModel) {
        self.media = media
    }
    
    func onStart() {
        switch media.mediaType {
        case .image:
            fetchImage()
        case .video:
            Task {
                await fetchVideo()
            }
        default:
            break
        }
    }
    
    func onStop() {
        subscriptions.cancelAll()
    }
    
    private func fetchImage() {
        let size = CGSize(width: media.source.pixelWidth, height: media.source.pixelHeight)
        media.source
            .image(size: size)
            .sink { [weak self] in
                self?.preview = $0
            }
            .store(in: &subscriptions)
    }
    
    private func fetchVideo() async {
        let url = await media.source.getURL()
        guard let url = url else {
            return
        }
        player = AVPlayer(url: url)
    }
}
