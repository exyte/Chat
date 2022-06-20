//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AssetsPicker
import UIKit.UIImage

final class MediaCellViewModel: ObservableObject {
    let media: Media
    let onDelete: () -> Void

    @Published var url: URL?
    @Published var image: UIImage?

    var showProgress: Bool {
        image == nil
    }
    var showVideoOverlay: Bool {
        return media.type == .video && image != nil
    }

    private var subscriptions = Set<AnyCancellable>()

    init(media: Media, onDelete: @escaping () -> Void) {
        self.media = media
        self.onDelete = onDelete
    }

    func delete() {
        onDelete()
    }

    func onStart() {
        media.getData()
            .compactMap {
                guard let data = $0 else { return nil }
                return UIImage(data: data)
            }
            .subscribe(on: DispatchQueue.main)
            .sink {
                self.image = $0
            }
            .store(in: &subscriptions)
    }

    func onStop() {
        subscriptions.removeAll()
    }
}
