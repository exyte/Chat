//
//  Conversation.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 20.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Conversation: Identifiable, Hashable {
    public let id: String
    public let users: [User]
    public let isGroup: Bool
    public let pictureURL: URL?
    public let title: String

    public let latestMessage: LatestMessageInChat?

    var notMeUsers: [User] {
        users.filter { $0.id != SessionManager.shared.currentUserId }
    }

    var displayTitle: String {
        if !isGroup, let user = notMeUsers.first {
            return user.name
        }
        return title
    }
}

public struct LatestMessageInChat: Hashable {
    public var senderName: String
    public var createdAt: Date?
    public var text: String?
    public var subtext: String?

    var isMyMessage: Bool {
        SessionManager.shared.currentUser?.name == senderName
    }
}

public struct FirestoreConversation: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    public let users: [String]
    public let isGroup: Bool
    public let pictureURL: String?
    public let title: String
    public let latestMessage: FirestoreMessage?
}
