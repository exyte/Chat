//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Chat

struct MockMessage {
    let uid: Int
    let sender: MockUser
    let createdAt: Date
    let text: String
}

extension MockMessage {
    func toChatMessage() -> Chat.Message {
        Chat.Message(
            id: uid,
            user: sender.toChatUser(),
            text: text,
            createdAt: createdAt
        )
    }
}
