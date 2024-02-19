//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import ExyteMediaPicker

public struct DraftMessage {
    public var id: String?
    public let text: String
    public let medias: [Media]
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date

    public init(id: String? = nil, 
                text: String,
                medias: [Media],
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.medias = medias
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}
