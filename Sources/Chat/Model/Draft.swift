//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public struct DraftMessage {
    public var id: String?
    public let text: String
    public let attachments: [any Attachment]
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date
}

extension Message {
    func toDraft() -> DraftMessage {
        DraftMessage(
            id: id,
            text: text,
            attachments: attachments,
            recording: recording,
            replyMessage: replyMessage,
            createdAt: Date()
        )
    }
}
