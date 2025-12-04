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
    let messageStyler: (String) -> AttributedString
    let shouldShowLinkPreview: (URL) -> Bool
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool
    let messageLinkPreviewLimit: Int
    let messageFont: UIFont

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
                    messageStyler: messageStyler,
                    shouldShowLinkPreview: shouldShowLinkPreview,
                    isDisplayingMessageMenu: isDisplayingMessageMenu,
                    showMessageTimeView: showMessageTimeView,
                    messageLinkPreviewLimit: messageLinkPreviewLimit,
                    font: messageFont
                )
            } else {
                customMessageView
            }
        }
        .id(row.message.id)
    }
}
