//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import Chat

struct MockImage {
    let thumbnail: URL
    let full: URL
}

extension MockImage {
    func toChatAttachment() -> any Attachment {
        ImageAttachment(
            thumbnail: thumbnail,
            full: full
        )
    }
}
