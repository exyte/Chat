//
//  Created by Alex.M on 27.05.2022.
//

import Foundation
import Photos

struct MediaModel {
    let source: PHAsset
}

extension MediaModel {
    var mediaType: MediaType? {
        switch source.mediaType {
        case .image:
            return .image
        case .video:
            return .video
        default:
            return nil
        }
    }
}

extension MediaModel: Identifiable {
    var id: String {
        source.localIdentifier
    }
}

extension MediaModel: Equatable {
    static func == (lhs: MediaModel, rhs: MediaModel) -> Bool {
        lhs.id == rhs.id
    }
}
