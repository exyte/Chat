//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    let onTapAttachment: (any Attachment) -> Void

    @Environment(\.messageUseMarkdown) var messageUseMarkdown

    var body: some View {
        VStack(spacing: 0) {
            MessageContainer(user: message.user) {
                VStack(alignment: .leading) {
                    if !message.text.isEmpty {
                        Group {
                            if messageUseMarkdown,
                               let attributed = try? AttributedString(markdown: message.text) {
                                Text(attributed)
                            } else {
                                Text(message.text)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                    }

                    if !message.attachments.isEmpty {
                        AttachmentsGrid(attachments: message.attachments, onTap: onTapAttachment)
                    }
                }
            }
            if let status = message.status {
                HStack {
                    Spacer()
                    Text(status.toString().capitalized)
                        .font(.footnote)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MessageView_Preview: PreviewProvider {
    static private var message = Message(
        id: 0,
        user: User(avatarURL: nil, isCurrentUser: true),
        status: .sending,
        text: "Hello"
    )

    static var previews: some View {
        MessageView(message: message, onTapAttachment: { _ in })
    }
}
