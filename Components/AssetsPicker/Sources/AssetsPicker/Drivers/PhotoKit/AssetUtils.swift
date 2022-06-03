//
//  File.swift
//  
//
//  Created by Alex.M on 30.05.2022.
//

import Foundation
import Combine
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
    static func data(from asset: PHAsset?) -> AnyPublisher<Data?, Never> {
        guard let asset = asset else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        let passthroughSubject = PassthroughSubject<Data?, Never>()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHCachingImageManager.default().requestImageDataAndOrientation(
            for: asset,
            options: options,
            resultHandler: { [passthroughSubject] data, _, _, info in
                passthroughSubject.send(data)
                if info?.keys.contains(PHImageResultIsDegradedKey) == false {
                    passthroughSubject.send(completion: .finished)
                }
            }
        )
        
        return passthroughSubject
            .eraseToAnyPublisher()
    }
    
#if os(iOS)
    static func image(from asset: PHAsset?, size: CGSize = CGSize(width: 100, height: 100)) -> AnyPublisher<UIImage?, Never> {
        guard let asset = asset else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        let passthroughSubject = PassthroughSubject<UIImage?, Never>()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHCachingImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options,
            resultHandler: { [passthroughSubject] image, info in
                passthroughSubject.send(image)
                if info?.keys.contains(PHImageResultIsDegradedKey) == false {
                    passthroughSubject.send(completion: .finished)
                }
            }
        )
        
        return passthroughSubject
            .eraseToAnyPublisher()
    }
#endif
}
