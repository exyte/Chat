//
//  Created by Alex.M on 31.05.2022.
//

import Foundation

public enum MediaType {
    case image
    case video
}

public struct Media {
    internal let source: Source
    public let type: MediaType
}

// MARK: - Public methods for get data from MediaItem
public extension Media {
    func getData(completion: @escaping (Data?) -> Void) {
        switch source {
        case .media(let media):
            completion(nil)
            // FIXME: Rewrite this to Combine
//            var data: Data?
//            AssetUtils.data(from: media.source)
//                .sink { result in
//                    if result == .finished {
//                        completion(data)
//                    } else {
//                        completion(nil)
//                    }
//                } receiveValue: { [&data] input in
//                    data = input
//                }
        case .url(let url):
            do {
                let data = try Data(contentsOf: url)
                completion(data)
            } catch {
                completion(nil)
            }
        }
    }
    
    func getUrl(completion: @escaping (URL?) -> Void) {
        switch source {
        case .url(let url):
            completion(url)
        case .media(let media):
            media.source.getURL(completion: completion)
        }
    }
}

// MARK: - Async -//-
public extension Media {
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

// MARK: - Media+Identifiable
extension Media: Identifiable {
    public var id: String {
        switch source {
        case .url(let url):
            return url.absoluteString
        case .media(let media):
            return media.id
        }
    }
}

// MARK: - Inner types
extension Media {
    enum Source {
        case media(MediaModel)
        case url(URL)
    }
}
