//
//  Created by Alex.M on 31.05.2022.
//

import Foundation
import Combine
import Photos

#if os(iOS)
import UIKit.UIImage
import UIKit.UIScreen
#endif

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
            PHImageManager
                .default()
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

#if os(iOS)
extension PHAsset {

    func image(size: CGSize = CGSize(width: 100, height: 100)) -> AnyPublisher<UIImage?, Never> {
        let requestSize = CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale)
        let passthroughSubject = PassthroughSubject<UIImage?, Never>()

        Task { [passthroughSubject] in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic

            // TODO: Cancel `requestImage` when returned Publisher is canceled
            PHCachingImageManager.default().requestImage(
                for: self,
                targetSize: requestSize,
                contentMode: .aspectFill,
                options: options,
                resultHandler: { [passthroughSubject] image, info in
                    DispatchQueue.main.async { [image, info] in
                        passthroughSubject.send(image)
                        if info?.keys.contains(PHImageResultIsDegradedKey) == false {
                            passthroughSubject.send(completion: .finished)
                        }
                    }
                }
            )
        }

        return passthroughSubject
            .eraseToAnyPublisher()
    }

    func data() async -> Data? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true

            PHCachingImageManager.default().requestImageDataAndOrientation(
                for: self,
                options: options,
                resultHandler: { data, _, _, info in
                    guard info?.keys.contains(PHImageResultIsDegradedKey) == false
                    else { fatalError("PHImageManager with `options.isSynchronous = true` should call result ONE time.") }
                    continuation.resume(returning: data)
                }
            )
        }
    }
}
#endif
