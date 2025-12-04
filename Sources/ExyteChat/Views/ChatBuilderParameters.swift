//
//  SwiftUIView.swift
//
//
//  Created by Alisa Mylnikova on 06.12.2023.
//

import SwiftUI

/// To build a custom message view use the following parameters passed by builder closure:
/// - message containing user, attachments, etc.
/// - position of message in its continuous group of messages from the same user
/// - position of message in the section of messages from that day
/// - position of message in its continuous group of comments (only works for .answer ReplyMode, nil for .quote mode)
/// - closure to show message context menu
/// - closure to pass user interaction, .reply for example
/// - pass attachment to this closure to use ChatView's fullscreen media viewer
public struct MessageBuilderParameters {
    let message: Message
    let positionInGroup: PositionInUserGroup
    let positionInMessagesSection: PositionInMessagesSection
    let positionInCommentsGroup: CommentsPosition?
    let showContextMenuClosure: () -> Void
    let messageActionClosure: (Message, DefaultMessageMenuAction) -> Void
    let showAttachmentClosure: (Attachment) -> Void
}

/// To build a custom input view use the following parameters passed by builder closure:
/// - binding to the text in input view
/// - InputViewAttachments to store the attachments from external pickers
/// - current input view state: .message for main input view mode and .signature for input view in media picker mode
/// - closure to pass user interaction, .recordAudioTap for example
/// - dismiss keyboard closure
public struct InputViewBuilderParameters {
    let text: Binding<String>
    let attachments: InputViewAttachments
    let inputViewState: InputViewState
    let inputViewStyle: InputViewStyle
    let inputViewActionClosure: (InputViewAction) -> Void
    let dismissKeyboardClosure: ()->()
}

extension ChatView {

    public typealias MessageBuilderParamsClosure = (_ params: MessageBuilderParameters) -> MessageContent

    public typealias InputViewBuilderParamsClosure = (_ params: InputViewBuilderParameters) -> InputViewContent

    /// To define custom message menu actions declare an enum conforming to MessageMenuAction. The library will show your custom menu options on long tap on message. Once the action is selected the following callback will be called:
    /// - action selected by the user from the menu. NOTE: when declaring this variable, specify its type (your custom descendant of MessageMenuAction) explicitly
    /// - a closure taking a case of default implementation of MessageMenuAction which provides simple actions handlers; you call this closure passing the selected message and choosing one of the default actions if you need them; or you can write a custom implementation for all your actions, in that case just ignore this closure
    /// - message for which the menu is displayed
    /// When implementing your own MessageMenuActionClosure, write a switch statement passing through all the cases of your MessageMenuAction, inside each case write your own action handler, or call the default one. NOTE: not all default actions work out of the box - e.g. for .edit you'll still need to provide a closure to save the edited text on your BE. Please see CommentsExampleView in ChatExample project for MessageMenuActionClosure usage example.
    public typealias MessageMenuActionClosure = (
        _ selectedMenuAction: MenuAction,
        _ defaultActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void,
        _ message: Message
    ) -> Void

    public init(
        messages: [Message],
        chatType: ChatType = .conversation,
        replyMode: ReplyMode = .quote,
        reactionDelegate: ReactionDelegate? = nil,
        messageBuilder: @escaping (_ params: MessageBuilderParameters) -> MessageContent = { _ in
            DummyView()
        },
        inputViewBuilder: @escaping (_ params: InputViewBuilderParameters) -> InputViewContent = { _ in
            DummyView()
        },
        messageMenuAction: MessageMenuActionClosure? = nil,
        localization: ChatLocalization = ChatLocalization.defaultLocalization,
        didUpdateAttachmentStatus: ((AttachmentUploadUpdate) -> Void)? = nil,
        didSendMessage: @escaping (DraftMessage) -> Void
    ) {
        self.type = chatType
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.localization = localization
        self.messageBuilder = messageBuilder
        self.inputViewBuilder = inputViewBuilder
        self.messageMenuAction = messageMenuAction ?? { (selectedMenuAction, defaultActionClosure, message) in
            if let action = selectedMenuAction as? DefaultMessageMenuAction {
                defaultActionClosure(message, action)
            }
        }
        self.didUpdateAttachmentStatus = didUpdateAttachmentStatus
        self.didSendMessage = didSendMessage
    }
}

public struct DummyView: View {
    public init() {}
    public var body: some View {
        EmptyView()
    }
}
