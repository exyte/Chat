//
//  Created by Alex.M on 26.05.2022.
//

import Foundation
import Photos

public final class PhotoProviderService: ObservableObject {
    @Published var photos: [Asset] = []
    @Published var albums: [Album] = []
    
    @Published var selectedAssetIds: [String] = []
    
    private var allPhotos = PHFetchResult<PHAsset>()
    private var smartAlbums = PHFetchResult<PHAssetCollection>()
    private var userCollections = PHFetchResult<PHAssetCollection>()
    
    public init() {}
    
    public func fetchAllPhotos() async {
        fetchAllPhotosAssets()
        let assets = await assets(from: allPhotos)
        DispatchQueue.main.async { [assets] in
            self.photos = assets
        }
    }
    
    public func fetchAlbums() async {
//        var albums = await getAllPhotoAlmub()
        var albums = await getSmartAlmubs()
        albums += await getUserAlmubs()
        DispatchQueue.main.async { [albums] in
            self.albums = albums
        }
    }
}

// MARK: - Support methods
private extension PhotoProviderService {
    func getSmartAlmubs() async -> [Album] {
        fetchSmartAlbums()
        return await albums(from: smartAlbums)
    }
    
    func getUserAlmubs() async -> [Album] {
        fetchUserCollections()
        return await albums(from: userCollections)
    }
}

// MARK: - Utils methods
// FIXME: Create some utils class with static func or enum namespace. After that update `Data` to calculated properties for optimization.
private extension PhotoProviderService {
    func assets(from fetchResult: PHFetchResult<PHAsset>) async -> [Asset] {
        var assets: [Asset] = []
        
        if fetchResult.count == 0 {
            return assets
        }

        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            // FIXME: When preview is nil, make placeholder
            if let preview = await self.loadData(from: asset) {
                assets.append(Asset(source: asset, preview: preview))
            }
        }
        return assets
    }
    
    func preview(from fetchResult: PHFetchResult<PHAsset>) async -> Data? {
        if let asset = fetchResult.firstObject {
            return await self.loadData(from: asset)
        } else {
            return nil
        }
    }
    
    func albums(from fetchResult: PHFetchResult<PHAssetCollection>) async -> [Album] {
        if fetchResult.count == 0 {
            return []
        }
        var albums: [Album] = []
        for index in 0...(fetchResult.count - 1) {
            let collection = fetchResult[index]
            let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            let preview = await preview(from: fetchResult)
            let assets = await assets(from: fetchResult)

            let album = Album(assets: assets, source: collection, preview: preview)
            albums.append(album)
        }
        return albums
    }

    func loadData(from asset: PHAsset) async -> Data? {
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: nil,
                resultHandler: { data, string, orientation, dict in
                    guard let data = data else {
                        continuation.resume(with: .success(nil))
                        return
                    }
                    continuation.resume(with: .success(data))
                }
            )
        }
    }
    
    func fetchAllPhotosAssets() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    func fetchSmartAlbums() {
        smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: nil
        )
    }
    
    func fetchUserCollections() {
        userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
    }
}
