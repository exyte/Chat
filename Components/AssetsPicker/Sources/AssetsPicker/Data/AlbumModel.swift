//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct AlbumModel {
    let preview: MediaModel?
    let source: PHAssetCollection
}

extension AlbumModel: Identifiable {
    var id: String {
        source.localIdentifier
    }
    
    var title: String? {
        source.localizedTitle
    }
}
