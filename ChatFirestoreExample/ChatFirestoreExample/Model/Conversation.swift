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
    public let pictureURL: URL?
    public let title: String

    public let latestMessage: LatestMessageInChat?
}

public struct FirestoreConversation: Codable, Identifiable, Hashable {
    @DocumentID public var id: String?
    public let users: [String]
    public let pictureURL: String?
    public let title: String
    public let latestMessage: FirestoreMessage?
}
