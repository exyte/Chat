//
//  Created by Alex.M on 07.06.2022.
//

import Foundation

enum AssetsPickerMode: Int, CaseIterable, Identifiable {
    case photos = 1
    case albums = 2
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .photos:
            return "Photos"
        case .albums:
            return "Albums"
        }
    }
}
