//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import Introspect

struct ChatView: View {
    var messages: [Message]
    var didSendMessage: (Message)->()
    
    @State private var scrollView: UIScrollView?

    var body: some View {
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

            InputView { message in
                didSendMessage(message)
                scrollToBottom()
            }
        }
        .onChange(of: messages) { _ in
            scrollToBottom()
        }
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
                Message(id: 5, imagesURLs: [
                    URL(string: "https://picsum.photos/200/300")!
                ]),
            ],
            didSendMessage: handleSendMessage
        )
    }
    
    static func handleSendMessage(message: Message) {
        print(message)
    }
}
