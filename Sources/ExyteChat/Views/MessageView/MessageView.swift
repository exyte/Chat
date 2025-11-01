//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {

    @Environment(\.chatTheme) var theme

    @ObservedObject var viewModel: ChatViewModel

    let message: Message
    let positionInUserGroup: PositionInUserGroup
    let positionInMessagesSection: PositionInMessagesSection
    let chatType: ChatType
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let messageStyler: (String) -> AttributedString
    let shouldShowLinkPreview: (URL) -> Bool
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool
    let messageLinkPreviewLimit: Int
    var font: UIFont

    @State var avatarViewSize: CGSize = .zero
    @State var statusSize: CGSize = .zero
    @State var giphyAspectRatio: CGFloat = 1
    @State var timeSize: CGSize = .zero
    @State var messageSize: CGSize = .zero

    // The size of our reaction bubbles are based on the users font size,
    // Therefore we need to capture it's rendered size in order to place it correctly
    @State var bubbleSize: CGSize = .zero

    static let widthWithMedia: CGFloat = 204
    static let horizontalScreenEdgePadding: CGFloat = 12
    static let horizontalNoAvatarPadding: CGFloat = horizontalScreenEdgePadding / 2
    static let horizontalAvatarPadding: CGFloat = 8
    static let horizontalTextPadding: CGFloat = 12
    static let attachmentPadding: CGFloat = 1  // for multiple attachments
    static let statusViewSize: CGFloat = 10
    static let horizontalStatusPadding: CGFloat = horizontalScreenEdgePadding / 2
    static let horizontalBubblePadding: CGFloat = 70

    enum DateArrangement {
        case hstack, vstack, overlay
    }

    var additionalMediaInset: CGFloat {
        message.attachments.count > 1 ? MessageView.attachmentPadding * 2 : 0
    }

    var dateArrangement: DateArrangement {
        let timeWidth = timeSize.width + 10
        let textPaddings = MessageView.horizontalTextPadding * 2
        let widthWithoutMedia =
            UIScreen.main.bounds.width
            - (message.user.isCurrentUser
                ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
            - statusSize.width
            - MessageView.horizontalBubblePadding
            - textPaddings

        let maxWidth =
            message.attachments.isEmpty
            ? widthWithoutMedia : MessageView.widthWithMedia - textPaddings
        let styledText = message.text.styled(using: messageStyler)

        let finalWidth = styledText.width(withConstrainedWidth: maxWidth, font: font)
        let lastLineWidth = styledText.lastLineWidth(labelWidth: maxWidth, font: font)
        let numberOfLines = styledText.numberOfLines(labelWidth: maxWidth, font: font)

        if !styledText.urls.isEmpty && messageLinkPreviewLimit > 0 {
            return .vstack
        }
        if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
            return .hstack
        }
        if lastLineWidth + CGFloat(timeWidth) < finalWidth {
            return .overlay
        }
        return .vstack
    }

    var showAvatar: Bool {
        isDisplayingMessageMenu
            || positionInUserGroup == .single
            || (chatType == .conversation && positionInUserGroup == .last)
            || (chatType == .comments && positionInUserGroup == .first)
    }

    var topPadding: CGFloat {
        if chatType == .comments { return 0 }
        return positionInUserGroup.isTop && !positionInMessagesSection.isTop ? 8 : 4
    }

    var bottomPadding: CGFloat {
        if chatType == .conversation { return 0 }
        return positionInUserGroup.isTop ? 8 : 4
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if !message.user.isCurrentUser {
                avatarView
            }

            VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isDisplayingMessageMenu, let reply = message.replyMessage?.toMessage() {
                    replyBubbleView(reply)
                        .opacity(theme.style.replyOpacity)
                        .padding(message.user.isCurrentUser ? .trailing : .leading, 10)
                        .overlay(alignment: message.user.isCurrentUser ? .trailing : .leading) {
                            Capsule()
                                .foregroundColor(theme.colors.mainTint)
                                .frame(width: 2)
                        }
                }

                bubbleView(message)
            }

            if message.user.isCurrentUser, let status = message.status {
                MessageStatusView(status: status) {
                    if case let .error(draft) = status {
                        viewModel.sendMessage(draft)
                    }
                }
                .sizeGetter($statusSize)
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .padding(.trailing, message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : 0)
        .padding(
            message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding
        )
        .frame(
            maxWidth: UIScreen.main.bounds.width,
            alignment: message.user.isCurrentUser ? .trailing : .leading)
    }

    @ViewBuilder
    func bubbleView(_ message: Message) -> some View {
        VStack(
            alignment: message.user.isCurrentUser ? .leading : .trailing,
            spacing: -bubbleSize.height / 3
        ) {
            if !isDisplayingMessageMenu && !message.reactions.isEmpty {
                reactionsView(message)
                    .zIndex(1)
            }

            VStack(alignment: .leading, spacing: 0) {

                if let giphyMediaId = message.giphyMediaId {
                    giphyView(giphyMediaId)
                }

                if !message.attachments.isEmpty {
                    attachmentsView(message)
                }

                if !message.text.isEmpty {
                    textWithTimeView(message)
                        .font(Font(font))
                }

                if let recording = message.recording {
                    VStack(alignment: .trailing, spacing: 8) {
                        recordingView(recording)
                        messageTimeView()
                            .padding(.bottom, 8)
                            .padding(.trailing, 12)
                    }
                }
            }
            .bubbleBackground(message, theme: theme)
            .zIndex(0)
        }
        .applyIf(isDisplayingMessageMenu) {
            $0.frameGetter($viewModel.messageFrame)
        }
    }

    @ViewBuilder
    func replyBubbleView(_ message: Message) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.user.name)
                .fontWeight(.semibold)
                .padding(.horizontal, MessageView.horizontalTextPadding)

            if !message.attachments.isEmpty {
                attachmentsView(message)
                    .padding(.top, 4)
                    .padding(.bottom, message.text.isEmpty ? 0 : 4)
            }

            if !message.text.isEmpty {
                MessageTextView(
                    text: message.text, messageStyler: messageStyler,
                    userType: message.user.type, shouldShowLinkPreview: shouldShowLinkPreview,
                    messageLinkPreviewLimit: messageLinkPreviewLimit
                )
                .padding(.horizontal, MessageView.horizontalTextPadding)
            }

            if let recording = message.recording {
                recordingView(recording)
            }
        }
        .font(.caption2)
        .padding(.vertical, 8)
        .frame(
            width: message.attachments.isEmpty
                ? nil : MessageView.widthWithMedia + additionalMediaInset
        )
        .bubbleBackground(message, theme: theme, isReply: true)
    }

    @ViewBuilder
    var avatarView: some View {
        Group {
            if showAvatar {
                if let url = message.user.avatarURL {
                    AvatarImageView(url: url, avatarSize: avatarSize, avatarCacheKey: message.user.avatarCacheKey)
                        .contentShape(Circle())
                        .onTapGesture {
                            tapAvatarClosure?(message.user, message.id)
                        }
                } else {
                    AvatarNameView(name: message.user.name, avatarSize: avatarSize)
                        .contentShape(Circle())
                        .onTapGesture {
                            tapAvatarClosure?(message.user, message.id)
                        }
                }

            } else {
                Color.clear.viewSize(avatarSize)
            }
        }
        .padding(.leading, MessageView.horizontalScreenEdgePadding)
        .padding(.trailing, MessageView.horizontalAvatarPadding)
        .sizeGetter($avatarViewSize)
    }

    @ViewBuilder
    func attachmentsView(_ message: Message) -> some View {
        AttachmentsGrid(attachments: message.attachments, isCurrentUser: message.user.isCurrentUser) { attachment, isCancel in
          if isCancel {
            let update = AttachmentUploadUpdate(
              messageId: message.id,
              attachmentId: attachment.id,
              updateAction: AttachmentUploadUpdate.UpdateAction.cancel
            )
            viewModel.updateAttachmentStatus(update)
          } else {
            viewModel.presentAttachmentFullScreen(attachment)
          }
        }
        .applyIf(message.attachments.count > 1) {
            $0
                .padding(.top, MessageView.attachmentPadding)
                .padding(.horizontal, MessageView.attachmentPadding)
        }
        .overlay(alignment: .bottomTrailing) {
            if message.text.isEmpty {
                messageTimeView(needsCapsule: true)
                    .padding(4)
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    func giphyView(_ giphyMediaId: String) -> some View {
        GiphyMediaView(id: giphyMediaId, aspectRatio: $giphyAspectRatio)
            .frame(width: 200 * giphyAspectRatio, height: 200)
    }

    @ViewBuilder
    func textWithTimeView(_ message: Message) -> some View {
        let messageView = MessageTextView(
            text: message.text, messageStyler: messageStyler,
            userType: message.user.type, shouldShowLinkPreview: shouldShowLinkPreview,
            messageLinkPreviewLimit: messageLinkPreviewLimit
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, MessageView.horizontalTextPadding)

        let timeView = messageTimeView()
            .padding(.horizontal, 12)

        Group {
            switch dateArrangement {
            case .hstack:
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    messageView
                    if !message.attachments.isEmpty {
                        Spacer()
                    }
                    timeView
                }
                .padding(.vertical, 8)
            case .vstack:
                VStack(alignment: .trailing, spacing: 4) {
                    messageView
                    timeView
                }
                .padding(.vertical, 8)
            case .overlay:
                messageView
                    .padding(.vertical, 8)
                    .overlay(alignment: .bottomTrailing) {
                        timeView
                            .padding(.vertical, 8)
                    }
            }
        }
    }

    @ViewBuilder
    func recordingView(_ recording: Recording) -> some View {
        RecordWaveformWithButtons(
            recording: recording,
            colorButton: message.user.isCurrentUser
                ? theme.colors.messageMyBG : theme.colors.mainBG,
            colorButtonBg: message.user.isCurrentUser
                ? theme.colors.mainBG : theme.colors.messageMyBG,
            colorWaveform: theme.colors.messageText(message.user.type)
        )
        .padding(.horizontal, MessageView.horizontalTextPadding)
        .padding(.top, 8)
    }

    func messageTimeView(needsCapsule: Bool = false) -> some View {
        Group {
            if showMessageTimeView {
                if needsCapsule {
                    MessageTimeWithCapsuleView(
                        text: message.time, isCurrentUser: message.user.isCurrentUser,
                        chatTheme: theme)
                } else {
                    MessageTimeView(
                        text: message.time, userType: message.user.type, chatTheme: theme)
                }
            }
        }
        .sizeGetter($timeSize)
    }
}

extension View {

    @ViewBuilder
    func bubbleBackground(_ message: Message, theme: ChatTheme, isReply: Bool = false) -> some View
    {
        let radius: CGFloat = !message.attachments.isEmpty ? 12 : 20
        let additionalMediaInset: CGFloat = message.attachments.count > 1 ? 2 : 0
        self
            .frame(
                width: message.attachments.isEmpty
                    ? nil : MessageView.widthWithMedia + additionalMediaInset
            )
            .foregroundColor(theme.colors.messageText(message.user.type))
            .background {
                if isReply || !message.text.isEmpty || message.recording != nil {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(theme.colors.messageBG(message.user.type))
                        .opacity(isReply ? theme.style.replyOpacity : 1)
                }
            }
            .cornerRadius(radius)
    }
}

#if DEBUG
    struct MessageView_Preview: PreviewProvider {
        static let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
        static let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)

        static private var extraShortText = "Sss"
        static private var extraShortTextWithNewline = "H\nJ"
        static private var shortText = "Hi, buddy!"
        static private var longText =
            "Hello hello hello hello hello hello hello hello hello hello hello hello hello\n hello hello hello hello d d d d d d d d"

        static private var replyedMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: longText,
            attachments: [
                Attachment.randomImage(),
                Attachment.randomImage(),
                Attachment.randomImage(),
                Attachment.randomImage(),
                Attachment.randomImage(),
            ],
            reactions: [
                Reaction(
                    user: john, createdAt: Date.now.addingTimeInterval(-70), type: .emoji("🔥"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-60), type: .emoji("🥳"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-50), type: .emoji("🤠"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-40), type: .emoji("🧠"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-30), type: .emoji("🥳"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-20), type: .emoji("🤯"),
                    status: .sent),
                Reaction(
                    user: john, createdAt: Date.now.addingTimeInterval(-10), type: .emoji("🥰"),
                    status: .sending),
            ]
        )

        static private var message = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: shortText,
            replyMessage: replyedMessage.toReplyMessage()
        )

        static private var shortMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: extraShortText
        )

        static private var extrShortMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: extraShortTextWithNewline
        )
        
        static var previews: some View {
            ZStack {
                Color.yellow.ignoresSafeArea()
                
                VStack {
                    MessageView(
                        viewModel: ChatViewModel(),
                        message: extrShortMessage,
                        positionInUserGroup: .single,
                        positionInMessagesSection: .single,
                        chatType: .conversation,
                        avatarSize: 32,
                        tapAvatarClosure: nil,
                        messageStyler: AttributedString.init,
                        shouldShowLinkPreview: { _ in true },
                        isDisplayingMessageMenu: false,
                        showMessageTimeView: true,
                        messageLinkPreviewLimit: 8,
                        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
                    )
                    
                    MessageView(
                        viewModel: ChatViewModel(),
                        message: replyedMessage,
                        positionInUserGroup: .single,
                        positionInMessagesSection: .single,
                        chatType: .conversation,
                        avatarSize: 32,
                        tapAvatarClosure: nil,
                        messageStyler: AttributedString.init,
                        shouldShowLinkPreview: { _ in true },
                        isDisplayingMessageMenu: false,
                        showMessageTimeView: true,
                        messageLinkPreviewLimit: 8,
                        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
                    )
                }
                
            }
        }
    }
#endif
