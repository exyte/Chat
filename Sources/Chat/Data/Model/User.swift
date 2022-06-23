//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public struct User {
    public let avatarURL: URL?
    public let isCurrentUser: Bool

    public init(avatarURL: URL?, isCurrentUser: Bool = false) {
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}
