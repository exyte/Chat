//
//  Created by Alex.M on 16.06.2022.
//

import Foundation

protocol Attachment: Equatable, Identifiable {
    var id: String { get }

    var thumbnail: URL { get }
}

struct ImageAttachment: Attachment {
    let id: String
    let thumbnail: URL
    let full: URL
    let name: String?

    init(id: String = UUID().uuidString, thumbnail: URL, full: URL, name: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.name = name
    }

#if DEBUG
    init(url: URL) {
        self.init(thumbnail: url, full: url)
    }
#endif
}

struct VideoAttachment: Attachment {
    let id: String
    let thumbnail: URL
    let full: URL
    let name: String?

    init(id: String = UUID().uuidString, thumbnail: URL, full: URL, name: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.name = name
    }

#if DEBUG
    init(url: URL) {
        self.init(thumbnail: url, full: url)
    }
#endif
}
