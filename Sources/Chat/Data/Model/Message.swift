//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

public struct Message {
    public var id: Int
    public var user: User
    public var status: Status?
    public var text: String
    public var attachments: [any Attachment]
    public var createdAt: Date

    public init(id: Int,
                user: User,
                status: Status? = nil,
                text: String = "",
                attachments: [any Attachment] = [],
                createdAt: Date = Date()) {

        self.id = id
        self.user = user
        self.status = status
        self.text = text
        self.attachments = attachments
        self.createdAt = createdAt
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Message {
    enum Status: Int {
        case sending
        case sent
        case read

        func toString() -> String {
            switch self {
            case .sending: return "sending"
            case .sent: return "sent"
            case .read: return "read"
            }
        }
    }
}
