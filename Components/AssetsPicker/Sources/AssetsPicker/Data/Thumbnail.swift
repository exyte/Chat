//
//  Created by Alex.M on 30.05.2022.
//

import Photos
#if os(iOS)
import UIKit.UIImage
#endif

struct Thumbnail {
#if os(iOS)
    let value: UIImage
#else
    let value: Data
#endif
}
