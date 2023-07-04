//
//  Conversation.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 20.06.2023.
//

import Foundation

public struct Conversation: Codable, Identifiable, Hashable {
    public let id: String
    public let users: [User]
}
