//
//  Created by Alex.M on 26.05.2022.
//

import Foundation
import Photos

final class AssetsService: ObservableObject {
    @Published var photos: [MediaModel] = []
    @Published var albums: [AlbumModel] = []
    @Published var selectedMedias: [MediaModel] = []
    
    var selectedItems: [MediaItem] {
        selectedMedias.map { MediaItem(source: .media($0)) }
    }
    
    let skipEmptyAlbums: Bool

    init(skipEmptyAlbums: Bool = false) {
        self.skipEmptyAlbums = skipEmptyAlbums
    }
    
    func fetchAllPhotos() async {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = await AssetUtils.medias(from: allPhotos)
        
        DispatchQueue.main.async { [assets] in
            self.photos = assets
        }
    }
    
    func fetchAlbums() async {
        var albums = await getSmartAlmubs()
        albums += await getUserAlmubs()
        DispatchQueue.main.async { [albums] in
            self.albums = albums
        }
    }
}

// MARK: - Support methods
private extension AssetsService {
    func getSmartAlmubs() async -> [AlbumModel] {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: smartAlbums)
    }
    
    func getUserAlmubs() async -> [AlbumModel] {
        let userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: userCollections)
    }
}
