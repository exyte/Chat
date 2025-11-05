//
//  Created by Alex.M on 16.06.2022.
//

import Foundation
import ExyteMediaPicker

public enum AttachmentType: String, Codable, Sendable {
    case image
    case video

    public var title: String {
        switch self {
        case .image:
            return "Image"
        default:
            return "Video"
        }
    }

    public init(mediaType: MediaType) {
        switch mediaType {
        case .image:
            self = .image
        default:
            self = .video
        }
    }
}

public struct Attachment: Codable, Identifiable, Hashable, Sendable {
    
    public enum UploadStatus: Sendable, Codable, Hashable {
        case inProgress(Int?) // value = percent upto 99%, nil no percent shown, progress indicator only
        case complete
        case cancelled
        case error
        
        public static func == (lhs: UploadStatus, rhs: UploadStatus) -> Bool {
            switch (lhs, rhs) {
            case (.error, .error):
                return true
            case (.complete, .complete):
                return true
            case (.cancelled, .cancelled):
                return true
            case (.inProgress(let lhsPercent), .inProgress(let rhsPercent)):
                return lhsPercent == rhsPercent
            default:
                return false
            }
        }
    }
    
    
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let fullUploadStatus: UploadStatus?
    public let type: AttachmentType
    public let thumbnailCacheKey: String?
    public let fullCacheKey: String?

    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType, thumbnailCacheKey: String? = nil,
                fullCacheKey: String? = nil, fullUploadStatus: UploadStatus? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
        self.thumbnailCacheKey = thumbnailCacheKey
        self.fullCacheKey = fullCacheKey
        self.fullUploadStatus = fullUploadStatus
    }

    public init(id: String, url: URL, type: AttachmentType, cacheKey: String? = nil) {
        self.init(id: id, thumbnail: url, full: url, type: type, thumbnailCacheKey: cacheKey, fullCacheKey: cacheKey)
    }
    
    public func copy(
        id: String? = nil,
        thumbnail: URL? = nil,
        full: URL? = nil,
        fullUploadStatus: UploadStatus? = nil,
        type: AttachmentType? = nil,
        thumbnailCacheKey: String? = nil,
        fullCacheKey: String? = nil
    ) -> Attachment {
        Attachment(
            id: id ?? self.id,
            thumbnail: thumbnail ?? self.thumbnail,
            full: full ?? self.full,
            type: type ?? self.type,
            thumbnailCacheKey: thumbnailCacheKey ?? self.thumbnailCacheKey,
            fullCacheKey: fullCacheKey ?? self.fullCacheKey,
            fullUploadStatus: fullUploadStatus ?? self.fullUploadStatus,
        )
    }
}
