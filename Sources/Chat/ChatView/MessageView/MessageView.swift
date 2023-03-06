//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {

    @Environment(\.chatTheme) private var theme

    @ObservedObject var viewModel: ChatViewModel

    let message: Message
    let positionInGroup: PositionInGroup
    let avatarSize: CGFloat
    let messageUseMarkdown: Bool

    var messageWidth: CGFloat {
        message.text.width(withConstrainedHeight: 1, font: .preferredFont(forTextStyle: .body))
    }

    var showAvatar: Bool {
        positionInGroup == .single || positionInGroup == .last
    }

    var topPadding: CGFloat {
        positionInGroup == .first || positionInGroup == .single ? 8 : 4
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if !message.user.isCurrentUser {
                Group {
                    if showAvatar {
                        AvatarView(url: message.user.avatarURL, avatarSize: avatarSize)
                    } else {
                        Color.clear.frame(width: avatarSize)
                    }
                }
                .padding(.horizontal, 8)
            } else {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                if !message.attachments.isEmpty {
                    AttachmentsGrid(attachments: message.attachments) {
                        viewModel.presentAttachmentFullScreen($0)
                    }
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
                    .contentShape(Rectangle())
                    .layoutPriority(2)
                }
                if !message.text.isEmpty {
                    if messageWidth >= UIScreen.main.bounds.width * 0.7 {
                        VStack(alignment: .trailing, spacing: 0) {
                            MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
                            MessageTimeView(
                                text: message.time,
                                isCurrentUser: message.user.isCurrentUser,
                                isOverlay: false
                            )
                            .padding(4)
                        }
                    } else {
                        HStack(alignment: .bottom, spacing: 0) {
                            MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
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
                MessageStatusView(status: status) {
                    viewModel.sendMessage(message.toDraft())
                }
            }

            if !message.user.isCurrentUser {
                Spacer()
            }
        }
        .padding(.top, topPadding)
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
            viewModel: ChatViewModel(),
            message: message,
            positionInGroup: .single,
            avatarSize: 32,
            messageUseMarkdown: false
        )
    }
}
