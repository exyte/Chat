//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {

    @Environment(\.chatTheme) private var theme

    let message: Message
    let hideAvatar: Bool
    let onTapAttachment: (any Attachment) -> Void
    let onRetry: () -> Void

    var messageWidth: CGFloat {
        message.text.width(withConstrainedHeight: 1, font: .preferredFont(forTextStyle: .body))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                if !message.user.isCurrentUser {
                    AvatarView(url: message.user.avatarURL, hideAvatar: hideAvatar)
                        .padding(.horizontal, 8)
                } else {
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 0) {
                    if !message.attachments.isEmpty {
                        AttachmentsGrid(attachments: message.attachments, onTap: onTapAttachment)
                            .overlay(alignment: .bottomTrailing) {
                                if message.text.isEmpty {
                                    MessageTimeView(
                                        text: message.time,
                                        isCurrentUser: message.user.isCurrentUser,
                                        isOverlay: true
                                    )
                                    .padding(4)
                                }
                            }
                            .layoutPriority(2)
                    }
                    if !message.text.isEmpty {
                        if messageWidth >= UIScreen.main.bounds.width * 0.7 {
                            VStack(alignment: .trailing, spacing: 0) {
                                MessageTextView(text: message.text)
                                MessageTimeView(
                                    text: message.time,
                                    isCurrentUser: message.user.isCurrentUser,
                                    isOverlay: false
                                )
                                .padding(4)
                            }
                        } else {
                            HStack(alignment: .bottom, spacing: 0) {
                                MessageTextView(text: message.text)
                                MessageTimeView(
                                    text: message.time,
                                    isCurrentUser: message.user.isCurrentUser,
                                    isOverlay: false
                                )
                                .padding(4)
                            }
                        }
                    }
                }
                .frame(width: message.attachments.isEmpty ? nil : 204)
                .foregroundColor(message.user.isCurrentUser ? .white : .black)
                .background {
                    if !message.text.isEmpty {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(message.user.isCurrentUser ? theme.colors.myMessage : theme.colors.friendMessage)
                    }
                }
                .padding(message.user.isCurrentUser ? .leading : .trailing, 20)

                if message.user.isCurrentUser, let status = message.status {
                    MessageStatusView(status: status, onRetry: onRetry)
                }
                if !message.user.isCurrentUser {
                    Spacer()
                }
            }
        }
        .padding(.bottom, hideAvatar ? 4 : 8)
    }
}

struct MessageView_Preview: PreviewProvider {
    static private var shortMessage = "Hi, buddy!"
    static private var longMessage = "Hello hello hello hello hello hello hello hello hello hello hello hello hello\n hello hello hello hello d d d d d d d d"

    static private var message = Message(
        id: UUID().uuidString,
        user: User(id: UUID().uuidString, avatarURL: nil, isCurrentUser: false),
        status: .read,
        text: longMessage,
        attachments: [
            ImageAttachment.random(),
            ImageAttachment.random(),
            ImageAttachment.random(),
            ImageAttachment.random(),
            ImageAttachment.random(),
        ]
    )

    static var previews: some View {
        MessageView(
            message: message,
            hideAvatar: false,
            onTapAttachment: { _ in },
            onRetry: { }
        )
    }
}
