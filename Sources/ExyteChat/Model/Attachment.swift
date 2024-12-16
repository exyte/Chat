//
//  Created by Alex.M on 16.06.2022.
//

import Foundation
import ExyteMediaPicker

public enum AttachmentType: Codable, Equatable {
    case image
    case video
    case file(_ file: File)

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

public struct Attachment: Codable, Identifiable, Hashable {
    public static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(full)
    }
    
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let type: AttachmentType

    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
    }

    public init(id: String, url: URL, type: AttachmentType) {
        self.init(id: id, thumbnail: url, full: url, type: type)
    }
}


public struct File: Codable, Hashable, Equatable {
    let filename: String
    let contentType: String
    let displayTitle: String
    let downloadUrl: String
    let `extension`: String
    let fileSize: Int
}
