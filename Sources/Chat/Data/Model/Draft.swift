//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import AssetsPicker

public struct DraftMessage {
    public let id: Int?
    public let text: String
    public let attachments: [any Attachment]
    public let createdAt: Date

    init(id: Int? = nil, text: String, attachments: [any Attachment], createdAt: Date) {
        self.id = id
        self.text = text
        self.attachments = attachments
        self.createdAt = createdAt
    }
}

extension Message {
    func toDraft() -> DraftMessage {
        DraftMessage(
            id: id,
            text: text,
            attachments: attachments,
            createdAt: Date()
        )
    }
}
