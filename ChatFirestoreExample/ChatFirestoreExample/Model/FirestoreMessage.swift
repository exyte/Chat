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
    public var attachments: [FirestoreAttachment]
    public var recording: Recording?
    public var replyMessage: FirestoreReply?
}

public struct FirestoreAttachment: Codable, Hashable {

    //public let thumbnail: URL
    public let url: String
    public let type: AttachmentType
}

public struct FirestoreReply: Codable, Hashable {

    @DocumentID public var id: String?
    public var userId: String

    public var text: String
    public var attachments: [FirestoreAttachment]
    public var recording: Recording?

}
