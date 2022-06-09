//
//  Created by Alex.M on 10.06.2022.
//

import Foundation
import Combine
import Photos

final class DefaultAlbumsProvider: AlbumsProviderProtocol {

    private var subject = CurrentValueSubject<[AlbumModel], Never>([])
    private var subscriptions = Set<AnyCancellable>()

    var albums: AnyPublisher<[AlbumModel], Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        photoLibraryChangePermissionPublisher
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
    }

    func reload() {
        [PHAssetCollectionType.album, .smartAlbum]
            .publisher
            .map { fetchAlbums(type: $0) }
            .scan([], +)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.subject.send($0)
            }
            .store(in: &subscriptions)
    }
}

private extension DefaultAlbumsProvider {

    func fetchAlbums(type: PHAssetCollectionType) -> [AlbumModel] {
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary, .typeiTunesSynced, .typeCloudShared]
        options.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]

        let collections = PHAssetCollection.fetchAssetCollections(
            with: type,
            subtype: .any,
            options: options
        )

        if collections.count == 0 {
            return []
        }
        var albums: [AlbumModel] = []

        for index in 0...(collections.count - 1) {
            let collection = collections[index]
            let options = PHFetchOptions()
            options.fetchLimit = 1
            let fetchResult = PHAsset.fetchAssets(in: collection, options: options)
            if fetchResult.count == 0 {
                continue
            }
            let preview = map(fetchResult: fetchResult).first
            let album = AlbumModel(preview: preview, source: collection)
            albums.append(album)
        }
        return albums
    }

    func map(fetchResult: PHFetchResult<PHAsset>) -> [MediaModel] {
        var medias: [MediaModel] = []

        if fetchResult.count == 0 {
            return medias
        }

        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            medias.append(MediaModel(source: asset))
        }
        return medias
    }
}
