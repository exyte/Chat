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
    static func assets(from fetchResult: PHFetchResult<PHAsset>) async -> [Asset] {
        var assets: [Asset] = []
        
        if fetchResult.count == 0 {
            return assets
        }
        
        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            // FIXME: When thumbnail is nil, make placeholder
            if let thumbnail = await AssetUtils.thumbnail(from: asset) {
                assets.append(Asset(source: asset, thumbnail: thumbnail))
            }
        }
        return assets
    }
    
    static func albums(from fetchResult: PHFetchResult<PHAssetCollection>) async -> [Album] {
        if fetchResult.count == 0 {
            return []
        }
        var albums: [Album] = []
        for index in 0...(fetchResult.count - 1) {
            let collection = fetchResult[index]
            let fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            if fetchResult.count == 0 {
                continue
            }
            let thumbnail = await AssetUtils.thumbnail(from: fetchResult.firstObject)
            let assets = await assets(from: fetchResult)
            
            let album = Album(assets: assets, source: collection, thumbnail: thumbnail)
            albums.append(album)
        }
        return albums
    }
}

// MARK: - Data/image from PHAsset
extension AssetUtils {
    static func data(from asset: PHAsset?) async -> Data? {
        guard let asset = asset else {
            return nil
        }
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
    
#if os(iOS)
    static func image(from asset: PHAsset?) async -> UIImage? {
        guard let asset = asset else {
            return nil
        }
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                contentMode: .aspectFit,
                options: nil,
                resultHandler: { image, dict in
                    guard let image = image else {
                        continuation.resume(with: .success(nil))
                        return
                    }
                    continuation.resume(with: .success(image))
                }
            )
        }
    }
#endif

    static func thumbnail(from asset: PHAsset?) async -> Thumbnail? {
        guard let asset = asset else {
            return nil
        }
#if os(iOS)
            let value = await image(from: asset)
#else
            let value = await data(from: asset)
#endif
        guard let value = value else {
            return nil
        }
        return Thumbnail(value: value)
    }
}
