//
//  ChatMessageView.swift
//
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI

struct ChatMessageView<MessageContent: View>: View {

    typealias MessageBuilderParamsClosure = ChatView<MessageContent, EmptyView, DefaultMessageMenuAction>.MessageBuilderParamsClosure

    @ObservedObject var viewModel: ChatViewModel

    var messageBuilder: MessageBuilderParamsClosure

    let row: MessageRow
    let chatType: ChatType
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let showMessageTimeView: Bool
    let timeViewWidth: CGFloat
    let shouldShowPreviewForLink: (URL) -> Bool
    let messageLinkPreviewLimit: Int
    let messageFont: UIFont
    let messageStyler: (String) -> AttributedString
    let isDisplayingMessageMenu: Bool

    @State var timeViewSize: CGSize?

    var body: some View {
        ZStack {
            let customMessageView = messageBuilder(
                MessageBuilderParameters(
                    message: row.message,
                    positionInGroup: row.positionInUserGroup,
                    positionInMessagesSection: row.positionInMessagesSection,
                    positionInCommentsGroup: row.commentsPosition,
                    showContextMenuClosure: { viewModel.messageMenuRow = row },
                    messageActionClosure: viewModel.messageMenuAction()
                ) { attachment in
                    self.viewModel.presentAttachmentFullScreen(attachment)
                }
            )

            if customMessageView is DummyView {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInUserGroup: row.positionInUserGroup,
                    positionInMessagesSection: row.positionInMessagesSection,
                    chatType: chatType,
                    avatarSize: avatarSize,
                    tapAvatarClosure: tapAvatarClosure,
                    showMessageTimeView: showMessageTimeView,
                    timeViewWidth: timeViewWidth,
                    shouldShowPreviewForLink: shouldShowPreviewForLink,
                    messageLinkPreviewLimit: messageLinkPreviewLimit,
                    messageFont: messageFont,
                    messageStyler: messageStyler,
                    isDisplayingMessageMenu: isDisplayingMessageMenu
                )
            } else {
                customMessageView
            }
        }
        .id(row.message.id)
    }
}
