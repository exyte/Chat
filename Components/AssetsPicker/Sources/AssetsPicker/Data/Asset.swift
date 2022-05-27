//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct Asset {
    let preview: Data
    let source: PHAsset
    
    init(source: PHAsset, preview: Data) {
        self.source = source
        self.preview = preview
    }
}

extension Asset: Identifiable {
    var id: String {
        source.localIdentifier
    }
}
