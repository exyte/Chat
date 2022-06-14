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
    var didSendMessage: (Message) -> Void
    
    @State private var scrollView: UIScrollView?

    @State private var message = Message(id: 0)
    @State private var isShownAttachments = false
    @State private var attachments: [Media]?

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                    }
                    .listRowSeparator(.hidden)
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }

                InputView(message: $message, attachments: $attachments) { message in
                    sendMessage(message)
                }
            }
            .onChange(of: messages) { _ in
                scrollToBottom()
            }
            if isShownAttachments, let attachments = attachments {
                Rectangle()
                    .fill(Color.black)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        AttachmentsView(
                            isShown: $isShownAttachments,
                            viewModel: AttachmentsViewModel(
                                attachments: attachments,
                                message: message.text,
                                onSend: { message in
                                    sendMessage(message)
                                }
                            )
                        )
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                    }
            }
        }
        .onChange(of: attachments) { newValue in
            isShownAttachments = newValue != nil
        }
        .onChange(of: isShownAttachments) { newValue in
            if !newValue {
                attachments = nil
            }
        }
    }
}

private extension ChatView {
    func sendMessage(_ message: Message) {
        didSendMessage(message)
        scrollToBottom()
        self.message = Message(id: 0)
        self.attachments = nil
    }

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
                Message(id: 0, text: "Text 1", isCurrentUser: false),
                Message(id: 1, text: "Text 2", isCurrentUser: true),
                Message(id: 5, attachments: [
                    ImageAttachment(url: URL(string: "https://picsum.photos/200/300")!)
                ]),
                Message(id: 6, text: "Text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text"),
            ],
            didSendMessage: handleSendMessage
        )
    }
    
    static func handleSendMessage(message: Message) {
        print(message)
    }
}
