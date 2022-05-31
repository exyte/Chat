//
//  Created by Alex.M on 31.05.2022.
//

import Foundation

public struct MediaItem {
    internal let source: Source
}

// MARK: - Public methods for get data from MediaItem
public extension MediaItem {
    func getData(complition: @escaping (Data?) -> Void) {
        switch source {
        case .media(let media):
            AssetUtils.data(from: media.source) { data in
                complition(data)
            }
        case .url(let url):
            do {
                let data = try Data(contentsOf: url)
                complition(data)
            } catch {
                complition(nil)
            }
        }
    }
    
    func getUrl(complition: @escaping (URL?) -> Void) {
        switch source {
        case .url(let url):
            complition(url)
        case .media(let media):
            media.source.getURL(completion: complition)
        }
    }
}

// MARK: - Async -//-
public extension MediaItem {
    func getData() async -> Data? {
        return await withCheckedContinuation { continuation in
            getData { data in
                continuation.resume(returning: data)
            }
        }
    }
    
    func getUrl() async -> URL? {
        return await withCheckedContinuation { continuation in
            getUrl { url in
                continuation.resume(returning: url)
            }
        }
    }
}

extension MediaItem {
    enum Source {
        case media(MediaModel)
        case url(URL)
    }
}
