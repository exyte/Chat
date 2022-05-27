//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct Album {
    var assets: [Asset]
    let source: PHAssetCollection
    let preview: Data?

    init(assets: [Asset], source: PHAssetCollection, preview: Data? = nil) {
        self.assets = assets
        self.source = source
        self.preview = preview
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
