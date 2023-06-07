//
//  Created by Alex.M on 16.06.2022.
//

import Foundation

public protocol Attachment: Equatable, Identifiable {
    var id: String { get }

    var thumbnail: URL { get }
    var full: URL { get }
}

public struct ImageAttachment: Attachment {
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let name: String?

    public init(id: String, thumbnail: URL, full: URL, name: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.name = name
    }

    public init(id: String, url: URL) {
        self.init(id: id, thumbnail: url, full: url)
    }
}

public struct VideoAttachment: Attachment {
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let name: String?

    public init(id: String, thumbnail: URL, full: URL, name: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.name = name
    }
}
