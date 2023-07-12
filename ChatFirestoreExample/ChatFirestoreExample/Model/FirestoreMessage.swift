//
//  FirestoreMessage.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.07.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Chat

public struct FirestoreMessage: Codable, Hashable {

    @DocumentID public var id: String?
    public var userId: String
    @ServerTimestamp public var createdAt: Date?

    public var text: String
    public var mediaURLs: [String]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?
}

public struct LatestMessageInChat: Hashable {

    public var senderName: String
    public var createdAt: Date?
    public var text: String?
    public var subtext: String?
}
