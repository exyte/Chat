//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

struct Message {
    var id: Int
    var author: Author

    var text: String = ""

    var attachments: [any Attachment] = []

    var createdAt: Date = Date()
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
