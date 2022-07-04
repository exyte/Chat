//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public struct User {
    public let id: String
    public let avatarURL: URL?
    public let isCurrentUser: Bool

    public init(id: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}
