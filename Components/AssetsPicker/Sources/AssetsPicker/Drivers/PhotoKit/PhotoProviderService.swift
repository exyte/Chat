//
//  Created by Alex.M on 26.05.2022.
//

import Foundation
import Photos
import UIKit

struct PHFetchResultCollection: RandomAccessCollection, Equatable {
    typealias Element = PHAsset
    typealias Index = Int

    let fetchResult: PHFetchResult<PHAsset>

    var endIndex: Int { fetchResult.count - 1 }
    var startIndex: Int { 0 }

    subscript(position: Int) -> PHAsset {
        fetchResult.object(at: reverseIndex(index: position))
    }
    
    private func reverseIndex(index: Int) -> Int {
        fetchResult.count - index - 1
    }
}

struct Album: Identifiable {
    let id = UUID()
    let title: String?
    let cover: UIImage?
    
    fileprivate let smart: Bool
    
    internal init(title: String? = nil, cover: UIImage? = nil, smart: Bool = false) {
        self.title = title
        self.cover = cover
        self.smart = smart
    }
}

public final class PhotoProviderService: ObservableObject {
    @Published var photos: [UIImage] = []
    @Published var albums: [Album] = []
    
    private var allPhotos = PHFetchResult<PHAsset>()
    private var smartAlbums = PHFetchResult<PHAssetCollection>()
    private var userCollections = PHFetchResult<PHAssetCollection>()
    
    public init() {
        
    }
    
    public func fetchAllPhotos() async {
        fetchAllPhotosAssets()
        if allPhotos.count == 0 {
            return
        }

        let collection = PHFetchResultCollection(fetchResult: allPhotos)
        
        var images: [UIImage] = []
        for index in collection.startIndex...collection.endIndex {
            let asset = collection[index]
            if let image = await self.loadImage(from: asset) {
                images.append(image)
            }
        }
        DispatchQueue.main.async { [images] in
            self.photos = images
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
    
    private func getAllPhotoAlmub() async -> [Album] {
        fetchAllPhotosAssets()
        
        var cover: UIImage?
        if let asset = allPhotos.firstObject {
            cover = await self.loadImage(from: asset)
        }
        
        return [Album(title: "All Photos", cover: cover, smart: false)]
    }
    
    private func getSmartAlmubs() async -> [Album] {
        fetchSmartAlbums()
        
        if smartAlbums.count == 0 {
            return []
        }
        var albums: [Album] = []
        for index in 0...(smartAlbums.count - 1) {
            let collection = smartAlbums[index]
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            var cover: UIImage?
            if let asset = assets.firstObject {
                cover = await self.loadImage(from: asset)
            }

            let album = Album(title: collection.localizedTitle, cover: cover, smart: true)
            albums.append(album)
        }
        return albums
    }
    
    private func getUserAlmubs() async -> [Album] {
        fetchUserCollections()
        
        if userCollections.count == 0 {
            return []
        }
        var albums: [Album] = []
        for index in 0...(userCollections.count - 1) {
            let collection = userCollections[index]
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            var cover: UIImage?
            if let asset = assets.firstObject {
                cover = await self.loadImage(from: asset)
            }

            let album = Album(title: collection.localizedTitle, cover: cover, smart: true)
            albums.append(album)
        }
        return albums
    }
}

private extension PhotoProviderService {
    func loadImage(from asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 100, height: 100),
                contentMode: .aspectFit,
                options: nil) { image, _ in
                    guard let image = image else {
                        continuation.resume(with: .success(nil))
                        return
                    }
                    continuation.resume(with: .success(image))
                }
        }
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
