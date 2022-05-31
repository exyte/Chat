//
//  File.swift
//  
//
//  Created by Alex.M on 30.05.2022.
//

import Foundation
import Photos

#if os(iOS)
import UIKit.UIImage
#endif

enum AssetUtils {}

// MARK: - Fetch assets from PhotoKit
extension AssetUtils {
    static func medias(from fetchResult: PHFetchResult<PHAsset>) async -> [MediaModel] {
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
    
    static func albums(from fetchResult: PHFetchResult<PHAssetCollection>) async -> [AlbumModel] {
        if fetchResult.count == 0 {
            return []
        }
        var albums: [AlbumModel] = []
        for index in 0...(fetchResult.count - 1) {
            let collection = fetchResult[index]
            let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            if fetchResult.count == 0 {
                continue
            }
            let medias = await medias(from: fetchResult)
            let album = AlbumModel(medias: medias, source: collection)
            albums.append(album)
        }
        return albums
    }
}

// MARK: - Data/UIImage from PHAsset
extension AssetUtils {
    static func data(from asset: PHAsset?, completion: @escaping (Data?) -> Void) {
        guard let asset = asset else {
            completion(nil)
            return
        }
        PHImageManager.default().requestImageDataAndOrientation(
            for: asset,
            options: nil,
            resultHandler: { data, string, orientation, dict in
                completion(data)
            }
        )
    }
    
#if os(iOS)
    static func image(from asset: PHAsset?, size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
        guard let asset = asset else {
            return completion(nil)
        }
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { image, dict in
                completion(image)
            }
        )
    }
#endif
}

// MARK: - Async Data/UIImage from PHAsset
extension AssetUtils {
    static func data(from asset: PHAsset?) async -> Data? {
        return await withCheckedContinuation { continuation in
            data(from: asset) { data in
                continuation.resume(returning: data)
            }
        }
    }
    
#if os(iOS)
    static func image(from asset: PHAsset?, size: CGSize = CGSize(width: 100, height: 100)) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            image(from: asset, size: size) { image in
                continuation.resume(returning: image)
            }
        }
    }
#endif
}
