//
//  Created by Alex.M on 26.05.2022.
//

import Foundation
import Photos

public final class AssetsService: ObservableObject {
    @Published var photos: [Asset] = []
    @Published var albums: [Album] = []
    @Published var selectedAssets: [Asset] = []
    
    let skipEmptyAlbums: Bool

    public init(skipEmptyAlbums: Bool = false) {
        self.skipEmptyAlbums = skipEmptyAlbums
    }
    
    public func fetchAllPhotos() async {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = await AssetUtils.assets(from: allPhotos)
        
        DispatchQueue.main.async { [assets] in
            self.photos = assets
        }
    }
    
    public func fetchAlbums() async {
        var albums = await getSmartAlmubs()
        albums += await getUserAlmubs()
        DispatchQueue.main.async { [albums] in
            self.albums = albums
        }
    }
}

// MARK: - Support methods
private extension AssetsService {
    func getSmartAlmubs() async -> [Album] {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: smartAlbums)
    }
    
    func getUserAlmubs() async -> [Album] {
        let userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: userCollections)
    }
}
