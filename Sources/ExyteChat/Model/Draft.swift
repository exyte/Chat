//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import GiphyUISDK
import ExyteMediaPicker

public struct DraftMessage: Sendable {
    public var id: String?
    public let text: String
    public let medias: [Media]
    public let documents: [DocumentItem]
    public let giphyMedia: GPHMedia?
    public let location: Location?
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date

    public init(id: String? = nil,
                text: String,
                medias: [Media],
                documents: [DocumentItem] = [],
                giphyMedia: GPHMedia?,
                location: Location? = nil,
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.medias = medias
        self.documents = documents
        self.giphyMedia = giphyMedia
        self.location = location
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}

