//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

public struct Message: Codable, Identifiable, Hashable {

    public enum Status: Int, Codable {
        case sending
        case sent
        case read
        case error
    }

    public var id: String
    public var user: User
    public var status: Status?
    public var createdAt: Date

    public var text: String
    public var attachments: [Attachment]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?

    public init(id: String,
                user: User,
                status: Status? = nil,
                createdAt: Date = Date(),
                text: String = "",
                attachments: [Attachment] = [],
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

    public init(id: String,
                user: User,
                status: Status? = nil,
                draft: DraftMessage) {

        self.id = id
        self.user = user
        self.status = status
        self.createdAt = draft.createdAt
        self.text = draft.text
        self.attachments = draft.attachments
        self.recording = draft.recording
        self.replyMessage = draft.replyMessage
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

public struct ReplyMessage: Codable, Identifiable, Hashable {
    public static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String
    public var user: User

    public var text: String
    public var attachments: [Attachment]
    public var recording: Recording?

    public init(id: String,
                user: User,
                text: String = "",
                attachments: [Attachment] = [],
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
