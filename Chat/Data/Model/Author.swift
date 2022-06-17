//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

struct Author {
    let avatarURL: URL?
    let isCurrentUser: Bool

    init(avatarURL: URL?, isCurrentUser: Bool = false) {
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}
