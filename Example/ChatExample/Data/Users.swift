//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Chat

extension User {
    static let tim = User(
        avatarURL: URL(string: "https://placeimg.com/640/480/animal"),
        isCurrentUser: true
    )
    static let steve = User(
        avatarURL: URL(string: "https://placeimg.com/640/480/arch"),
        isCurrentUser: false
    )
}
