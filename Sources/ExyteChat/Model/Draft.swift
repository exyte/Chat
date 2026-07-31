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
    public let giphyMedia: GPHMedia?
    public let documents: [DocumentItem]
    public let staticLocation: StaticLocation?
    public let liveLocation: LiveLocation?
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date

    public init(
        id: String? = nil,
        text: String,
        medias: [Media],
        giphyMedia: GPHMedia?,
        documents: [DocumentItem] = [],
        staticLocation: StaticLocation? = nil,
        liveLocation: LiveLocation? = nil,
        recording: Recording?,
        replyMessage: ReplyMessage?,
        createdAt: Date
    ) {
        self.id = id
        self.text = text
        self.medias = medias
        self.giphyMedia = giphyMedia
        self.documents = documents
        self.staticLocation = staticLocation
        self.liveLocation = liveLocation
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}

