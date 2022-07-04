//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {
    let message: Message
    let hideAvatar: Bool
    let onTapAttachment: (any Attachment) -> Void
    let onRetry: () -> Void

    @Environment(\.messageUseMarkdown) var messageUseMarkdown

    var body: some View {
        VStack(spacing: 0) {
            MessageContainer(user: message.user, hideAvatar: hideAvatar) {
                HStack {
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
                    if message.status == .error {
                        retryButton
                    }
                }
            }
            if let status = message.status, status != .error {
                statusView(status: status)
            }
        }
    }
}

private extension MessageView {
    func statusView(status: Message.Status) -> some View {
        HStack {
            Spacer()
            Group {
                switch status {
                case .sending:
                    Text("Sending")
                case .sent:
                    Text("Sent")
                case .read:
                    Text("Read")
                case .error:
                    EmptyView()
                }
            }
            .font(.footnote)
        }
        .padding(.horizontal)
    }

    var retryButton: some View {
        Button {
            onRetry()
        } label: {
            Image(systemName: "exclamationmark.arrow.circlepath")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .foregroundColor(.red)
        .padding(.trailing)
    }
}

struct MessageView_Preview: PreviewProvider {
    static private var message = Message(
        id: UUID().uuidString,
        user: User(id: UUID().uuidString, avatarURL: nil, isCurrentUser: true),
        status: .error,
        text: "Hello"
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
