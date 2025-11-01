//
//  CommentsExampleView.swift
//  ChatExample
//
//  Created by Alisa Mylnikova on 28.06.2024.
//

import SwiftUI
import ExyteChat

enum Action: MessageMenuAction {
    case reply, edit, delete, print

    func title() -> String {
        switch self {
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        case .delete:
            "Delete"
        case .print:
            "Print"
        }
    }
    
    func icon() -> Image {
        switch self {
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            Image(systemName: "square.and.pencil")
        case .delete:
            Image(systemName: "xmark.bin")
        case .print:
            Image(systemName: "printer")
        }
    }
    
    static func menuItems(for message: ExyteChat.Message) -> [Action] {
        if message.user.isCurrentUser  {
            return [.edit]
        } else {
            return [.reply]
        }
    }
}

struct CommentsExampleView: View {

    @StateObject var viewModel = ChatExampleViewModel()

    var body: some View {
        VStack {
            ZStack {
                Color.blue.opacity(0.2)
                Text("An interesting post for people to comment on")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(30)
            }
            .fixedSize(horizontal: false, vertical: true)

            ChatView(messages: viewModel.messages, chatType: .comments, replyMode: .answer) { draft in
                viewModel.send(draft: draft)
            } messageBuilder: {
                message, positionInGroup, positionInMessagesSection, positionInCommentsGroup,
                showContextMenuClosure, messageActionClosure, showAttachmentClosure in
                messageCell(message, positionInCommentsGroup, showMenuClosure: showContextMenuClosure, actionClosure: messageActionClosure, attachmentClosure: showAttachmentClosure)
            } messageMenuAction: { (action: Action, defaultActionClosure, message) in
                switch action {
                case .reply:
                    defaultActionClosure(message, .reply)
                case .edit:
                    defaultActionClosure(message, .edit { editedText in
                        // update this message's text in your datasource
                        print(editedText)
                    })
                case .delete:
                    // delete this message in your datasource
                    viewModel.messages.removeAll { msg in
                        msg.id == message.id
                    }
                case .print:
                    print(message.text)
                }
            }
            .showDateHeaders(false)
            .swipeActions(edge: .leading, performsFirstActionWithFullSwipe: false, items: [
                // SwipeActions are similar to Buttons, they accept an Action and a ViewBuilder
                SwipeAction(action: onDelete, activeFor: { $0.user.isCurrentUser }, background: .red) {
                    swipeActionButtonStandard(title: "Delete", image: "xmark.bin")
                },
                SwipeAction(action: onReply, background: .blue) {
                    swipeActionButtonStandard(title: "Reply", image: "arrowshape.turn.up.left")
                },
                // SwipeActions can also be selectively shown based on the message, here we only show the Edit action when the message is from the current sender
                SwipeAction(action: onEdit, activeFor: { $0.user.isCurrentUser }, background: .gray) {
                    swipeActionButtonStandard(title: "Edit", image: "bubble.and.pencil")
                }
            ])
            // Just like with UITableView's we can enable, or disable, `performsFirstActionWithFullSwipe` triggering the first action
            .swipeActions(edge: .trailing, performsFirstActionWithFullSwipe: true, items: [
                SwipeAction(action: onInfo) {
                    Image(systemName: "info.bubble")
                        .imageScale(.large)
                        .foregroundStyle(.blue.gradient)
                        .frame(height: 30)
                    Text("Info")
                        .foregroundStyle(.blue.gradient)
                        .font(.footnote)
                }
            ])
        }
        .navigationTitle("Comments example")
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }

    @ViewBuilder
    func messageCell(_ message: Message, _ commentsPosition: CommentsPosition?, showMenuClosure: @escaping ()->(), actionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void, attachmentClosure: @escaping (Attachment) -> Void) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                CachedAsyncImage(
                    url: message.user.avatarURL,
                    cacheKey: message.user.avatarCacheKey
                ) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(message.user.name)
                            .font(.system(size: 14)).fontWeight(.semibold)
                        Spacer()
                        Text(message.createdAt.formatAgo())
                            .font(.system(size: 12)).fontWeight(.medium)
                    }

                    if !message.text.isEmpty {
                        Text(message.text)
                            .font(.system(size: 12)).fontWeight(.medium)
                            .foregroundStyle(.gray)
                    }

                    if !message.attachments.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 8) {
                            ForEach(message.attachments) { attachment in
                                AttachmentCell(attachment: attachment, size: CGSize(width: 150, height: 150)) { _,_ in
                                    attachmentClosure(attachment)
                                }
                                .cornerRadius(12)
                                .clipped()
                            }
                        }
                        .frame(width: 308)
                    }

                    HStack {
                        if message.replyMessage == nil {
                            Group {
                                Image(systemName: "bubble")
                                    .padding(.top, 4)
                                Text("Reply")
                                    .font(.system(size: 14)).fontWeight(.medium)
                            }
                            .onTapGesture {
                                actionClosure(message, .reply)
                            }
                        }

                        Spacer()
                    }
                }
            }
            .padding(.leading, message.replyMessage != nil ? 40 : 0)

            if let commentsPosition {
                if commentsPosition.isLastInCommentsGroup {
                    Color.gray.frame(height: 0.5)
                        .padding(.vertical, 10)
                } else if commentsPosition.isLastInChat {
                    Color.clear.frame(height: 5)
                } else {
                    Color.clear.frame(height: 10)
                }
            }
        }
        .padding(.horizontal, 18)
    }
}

// MARK: - Swipe Actions
extension CommentsExampleView {
    
    /// `message` - message the swipe action was triggered on
    /// `defaultActions` - closure to perform default ChatView actions such as .reply, .edit, or .copy
    
    func onDelete(message: Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Delete: \(message)")
        // Delete the message from your message provider
    }
    
    func onReply(message: Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Reply: \(message)")
        // This places the message in the ChatView's InputView ready for the sender to reply
        defaultActions(message, .reply)
    }
    
    func onEdit(message: Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Edit: \(message)")
        // This places the message in the ChatView's InputView ready for the sender to edit it
        defaultActions(message, .edit(saveClosure: { msg in
            print("Edited Message: \(msg)")
            // Update the message in your message provider
        }))
    }
    
    func onInfo(message:Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Info: \(message)")
        // Maybe navigate to a details page?
    }
    
    // standard swipe button with an image and label in a white foregroundStyle
    func swipeActionButtonStandard(title: String, image: String) -> some View {
        VStack {
            Image(systemName: image)
                .imageScale(.large)
                .foregroundStyle(.white)
                .frame(height: 30)
            Text(title)
                .foregroundStyle(.white)
                .font(.footnote)
        }
    }
}
