//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct Album {
    var assets: [Asset]
    let source: PHAssetCollection
    let thumbnail: Thumbnail?

    init(assets: [Asset], source: PHAssetCollection, thumbnail: Thumbnail? = nil) {
        self.assets = assets
        self.source = source
        self.thumbnail = thumbnail
    }
}

extension Album: Identifiable {
    var id: String {
        source.localIdentifier
    }
    
    var title: String? {
        source.localizedTitle
    }
}
