//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos

final class AlbumMediasProvider: MediasProviderProtocol {
    
    private var subject = CurrentValueSubject<[MediaModel], Never>([])
    private var subscriptions = Set<AnyCancellable>()

    let album: AlbumModel

    var medias: AnyPublisher<[MediaModel], Never> {
        subject.eraseToAnyPublisher()
    }

    init(album: AlbumModel) {
        self.album = album
        photoLibraryChangePermissionPublisher
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
    }

    func reload() {
        let fetchResult = PHAsset.fetchAssets(in: album.source, options: nil)
        if fetchResult.count == 0 {
            subject.send([])
        }
        let assets = map(fetchResult: fetchResult)
        subject.send(assets)
    }
}
