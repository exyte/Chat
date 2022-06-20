//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import Introspect
import AssetsPicker

struct ChatView: View {
    var messages: [Message]
    var didSendMessage: (DraftMessage) -> Void

    @State private var scrollView: UIScrollView?
    @StateObject private var draftViewModel = DraftViewModel()

    // TODO: Inject parser from outside of library
    @StateObject private var messageViewModel: MessageViewModel = MessageViewModel()

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(messages, id: \.id) { message in
                        MessageView(
                            viewModel: messageViewModel,
                            message: message
                        )
                    }
                    .listRowSeparator(.hidden)
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }

                InputView(draftViewModel: draftViewModel)
            }
            .onChange(of: messages) { _ in
                scrollToBottom()
            }
            if draftViewModel.isShownAttachments {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        AttachmentsView(
                            viewModel: AttachmentsViewModel(
                                draftViewModel: draftViewModel
                            )
                        )
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                    }
            }
        }
        .onAppear {
            draftViewModel.didSendMessage = { [self] value in
                self.didSendMessage(value)
                self.scrollToBottom() // TODO: Make sure have no retain cycle
            }
        }
    }
}

private extension ChatView {
    func scrollToBottom() {
        if let scrollView = scrollView {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height)
        }
    }
}

struct ChatView_Preview: PreviewProvider {
    static var previews: some View {
        ChatView(
            messages: [
                Message(id: 0, author: .steve, text: "Text 1"),
                Message(id: 1, author: .tim),
                Message(id: 5, author: .steve, attachments: [
                    ImageAttachment(url: URL(string: "https://picsum.photos/200/300")!)
                ]),
                Message(id: 6, author: .tim, text: "Text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text"),
            ],
            didSendMessage: handleSendMessage
        )
    }
    
    static func handleSendMessage(message: DraftMessage) {
        print(message)
    }
}
