//
//  Created by Alex.M on 28.06.2022.
//

import SwiftUI
import ExyteChat
import ActivityIndicatorView

enum ChatExampleMenuAction: MessageMenuAction {
    case copy, reply, edit, delete

    func title() -> String {
        switch self {
        case .copy: "Copy"
        case .reply: "Reply"
        case .edit: "Edit"
        case .delete: "Delete"
        }
    }

    func icon() -> Image {
        switch self {
        case .copy: Image(systemName: "doc.on.doc")
        case .reply: Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            if #available(iOS 18.0, macCatalyst 18.0, *) {
                Image(systemName: "bubble.and.pencil")
            } else {
                Image(systemName: "square.and.pencil")
            }
        case .delete: Image(systemName: "trash")
        }
    }

    func isDestructive() -> Bool { self == .delete }

    static func menuItems(for message: Message) -> [ChatExampleMenuAction] {
        message.user.isCurrentUser ? [.copy, .reply, .edit, .delete] : [.copy, .reply]
    }
}

@MainActor
struct ChatExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = ChatExampleViewModel()

    @State var text = ""

    private var steve = MockChatData.shared.steve
    let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)
    
    var body: some View {
        ChatView(
            messages: viewModel.messages,
            chatType: .conversation,
            didSendMessage: { draft in
                viewModel.send(draft: draft)
            },
            messageMenuAction: { (action: ChatExampleMenuAction, defaultActionClosure, message) in
                switch action {
                case .copy:
                    defaultActionClosure(message, .copy)
                case .reply:
                    defaultActionClosure(message, .reply)
                case .edit:
                    defaultActionClosure(message, .edit { editedText in
                        // update this message in your datasource
                        print(editedText)
                    })
                case .delete:
                    viewModel.remove(messageID: message.id)
                }
            }
        )
        .enableLoadMoreNewerMessages(triggerType: .pixels(0), hasMoreToLoad: viewModel.newPagesCount < viewModel.maxNewPagesCount) {
            await viewModel.loadNewerMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleBlue))
        }
        .enableLoadMoreOlderMessages(triggerType: .pixels(0)) {
            await viewModel.loadOlderMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleGrey))
        }
        .mainHeaderBuilder { mainHeaderView }
        .updateTransaction($viewModel.tableTransaction)
        .scrollTo(viewModel.scrollToParams)
        .inputViewText($text)
        .keyboardDismissMode(.interactive)
        .setMediaPickerLiveCameraStyle(.prominant)
        .setRecorderSettings(recorderSettings)
        .messageReactionDelegate(viewModel)
        .setAvailableInputs([.text, .media, .giphy, .audio])
        .swipeActions(edge: .leading, performsFirstActionWithFullSwipe: true, items: [replyAction])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            backToolbarItem
            titleToolbarItem
        }
        .onChange(of: text) { oldValue, newValue in
            print(newValue)
        }
    }

    var activityIndicatorView: some View {
        ActivityIndicatorView(type: .default())
            .frame(width: 30, height: 30)
            .padding(.vertical, 10)
    }

    // Swipe Action
    func onReply(message: Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Reply: \(message)")
        // This places the message in the ChatView's InputView ready for the sender to reply
        defaultActions(message, .reply)
    }

    var replyAction: SwipeAction {
        SwipeAction(action: onReply, activeFor: { !$0.user.isCurrentUser }, background: .blue) {
            VStack {
                Image(systemName: "arrowshape.turn.up.left")
                    .imageScale(.large)
                    .foregroundStyle(.white)
                    .frame(height: 30)
                Text("Reply")
                    .foregroundStyle(.white)
                    .font(.footnote)
            }
        }
    }

    var backToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image("backArrow", bundle: .current)
                    .renderingMode(.template)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
    }

    var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                if let url = steve.avatarURL {
                    CachedAsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Rectangle().fill(Color(hex: "AFB3B8"))
                        }
                    }
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 0) {
                        Text(steve.name)
                            .fontWeight(.semibold)
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        Text("online")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "AFB3B8"))
                    }
                }
            }
            .padding(.leading, 10)
        }
    }

    var mainHeaderView: some View {
        Text("This view is on top")
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(Color(.exampleBlue))
            .cornerRadius(10)
            .padding(.horizontal, 15)
    }
}
