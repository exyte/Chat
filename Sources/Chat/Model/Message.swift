//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

public struct Message {
    public var id: String
    public var user: User
    public var status: Status?
    public var createdAt: Date

    public var text: String
    public var attachments: [any Attachment]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?

    public init(id: String,
                user: User,
                status: Status? = nil,
                createdAt: Date = Date(),
                text: String = "",
                attachments: [any Attachment] = [],
                recording: Recording? = nil,
                replyMessage: ReplyMessage? = nil) {

        self.id = id
        self.user = user
        self.status = status
        self.createdAt = createdAt
        self.text = text
        self.attachments = attachments
        self.recording = recording
        self.replyMessage = replyMessage
    }
}

extension Message {
    var time: String {
        DateFormatter.timeFormatter.string(from: createdAt)
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status
    }
}

public extension Message {
    enum Status: Int {
        case sending
        case sent
        case read
        case error
    }
}

public struct ReplyMessage {
    public var id: String
    public var user: User

    public var text: String
    public var attachments: [any Attachment]
    public var recording: Recording?

    public init(id: String,
                user: User,
                text: String = "",
                attachments: [any Attachment] = [],
                recording: Recording? = nil) {

        self.id = id
        self.user = user
        self.text = text
        self.attachments = attachments
        self.recording = recording
    }

    func toMessage() -> Message {
        Message(id: id, user: user, text: text, attachments: attachments, recording: recording)
    }
}

public extension Message {

    func toReplyMessage() -> ReplyMessage {
        ReplyMessage(id: id, user: user, text: text, attachments: attachments, recording: recording)
    }
}
