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
    let messageParams: MessageCustomizationParameters
    @Binding var timeViewWidth: CGFloat
    @Binding var reactionViewWidth: CGFloat
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
                    messageActionClosure: viewModel.messageMenuAction(),
                    showAttachmentClosure: { attachment in
                        self.viewModel.presentAttachmentFullScreen(attachment)
                    }
                )
            )

            if customMessageView is DummyView {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInUserGroup: row.positionInUserGroup,
                    positionInMessagesSection: row.positionInMessagesSection,
                    chatType: chatType,
                    params: messageParams,
                    timeViewWidth: $timeViewWidth,
                    reactionViewWidth: $reactionViewWidth,
                    isDisplayingMessageMenu: isDisplayingMessageMenu
                )
            } else {
                customMessageView
                    .environmentObject(viewModel)
                    .environment(\.chatMessageType, chatType)
                    .environment(\.messageCustomizationParams, messageParams)
                    .environment(\.timeViewWidthBinding, $timeViewWidth)
                    .environment(\.reactionViewWidthBinding, $reactionViewWidth)
            }
        }
        .id(row.message.id)
    }
}
