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
    let images: [MockImage]

    init(uid: Int, sender: MockUser, createdAt: Date, text: String, images: [MockImage] = []) {
        self.uid = uid
        self.sender = sender
        self.createdAt = createdAt
        self.text = text
        self.images = images
    }
}

extension MockMessage {
    func toChatMessage() -> Chat.Message {
        Chat.Message(
            id: uid,
            user: sender.toChatUser(),
            text: text,
            attachments: images.map { $0.toChatAttachment() },
            createdAt: createdAt
        )
    }
}
