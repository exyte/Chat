//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Chat

struct MockMessage {
    let uid: String
    let sender: MockUser
    let createdAt: Date
    var status: Message.Status?

    let text: String
    let images: [MockImage]

    init(uid: String, sender: MockUser, createdAt: Date, status: Message.Status?, text: String, images: [MockImage] = []) {
        self.uid = uid
        self.sender = sender
        self.createdAt = createdAt
        self.status = status
        self.text = text
        self.images = images
    }
}

extension MockMessage {
    func toChatMessage() -> Chat.Message {
        Chat.Message(
            id: uid,
            user: sender.toChatUser(),
            status: status,
            text: text,
            attachments: images.map { $0.toChatAttachment() },
            createdAt: createdAt
        )
    }
}
