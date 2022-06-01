//
//  File.swift
//  
//
//  Created by Alex.M on 31.05.2022.
//

import Foundation
import Photos

extension PHAsset {
    func getURL(completion: @escaping (URL?) -> Void) {
        if mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ -> Bool in
                return true
            }
            requestContentEditingInput(
                with: options,
                completionHandler: { (contentEditingInput, _) in
                    completion(contentEditingInput?.fullSizeImageURL)
                }
            )
        } else if mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default()
                .requestAVAsset(
                    forVideo: self,
                    options: options,
                    resultHandler: { (asset, _, _) in
                        if let urlAsset = asset as? AVURLAsset {
                            completion(urlAsset.url)
                        } else {
                            completion(nil)
                        }
                    }
                )
        }
    }
    
    var formattedDuration: String? {
        guard mediaType == .video || mediaType == .audio else {
            return nil
        }
        return duration.formatted()
    }
}

extension PHAsset {
    func getURL() async -> URL? {
        return await withCheckedContinuation { continuation in
            getURL { url in
                continuation.resume(returning: url)
            }
        }
    }
}
