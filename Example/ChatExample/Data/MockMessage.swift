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
    let recording: Recording?
    let replyMessage: ReplyMessage?
}

extension MockMessage {
    func toChatMessage() -> Chat.Message {
        Chat.Message(
            id: uid,
            user: sender.toChatUser(),
            status: status,
            createdAt: createdAt,
            text: text,
            attachments: images.map { $0.toChatAttachment() },
            recording: recording,
            replyMessage: replyMessage
        )
    }
}
