//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

public struct Asset {
    let thumbnail: Thumbnail
    public let source: PHAsset
    
    init(source: PHAsset, thumbnail: Thumbnail) {
        self.source = source
        self.thumbnail = thumbnail
    }
}

extension Asset: Identifiable {
    public var id: String {
        source.localIdentifier
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }
}
