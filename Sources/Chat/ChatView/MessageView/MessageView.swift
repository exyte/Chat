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
                            messageTimeView(isOverlay: true)
                        }
                    }
                    .contentShape(Rectangle())
                    .layoutPriority(2)
                }

                if !message.text.isEmpty {
                    if messageWidth >= UIScreen.main.bounds.width * 0.7 {
                        VStack(alignment: .trailing, spacing: 0) {
                            MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
                            messageTimeView()
                        }
                        .border(Color.red, width: 2)
                    } else {
                        HStack(alignment: .bottom, spacing: 0) {
                            MessageTextView(text: message.text, messageUseMarkdown: messageUseMarkdown)
                            messageTimeView()
                        }
                    }
                }

                if let recording = message.recording {
                    VStack(alignment: .trailing, spacing: 0) {
                        RecordWaveformWithButtons(
                            recording: recording,
                            colorButton: message.user.isCurrentUser ? theme.colors.myMessage : .white,
                            colorButtonBg: message.user.isCurrentUser ? .white : theme.colors.myMessage,
                            colorWaveform: message.user.isCurrentUser ? theme.colors.textDarkContext : theme.colors.textLightContext
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 8)

                        messageTimeView()
                    }
                }
            }
            .frame(width: message.attachments.isEmpty ? nil : 204)
            .foregroundColor(message.user.isCurrentUser ? theme.colors.textDarkContext : theme.colors.textLightContext)
            .background {
                if !message.text.isEmpty || message.recording != nil {
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

    func messageTimeView(isOverlay: Bool = false) -> some View {
        MessageTimeView(
            text: message.time,
            isCurrentUser: message.user.isCurrentUser,
            isOverlay: isOverlay
        )
        .padding(4)
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
