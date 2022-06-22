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
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message) { attachment in
                            viewModel.attachmentsFullscreenState.showFullscreen.value = attachment
                        }
                    }
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }

                InputView(
                    viewModel: inputViewModel,
                    onTapAttach: {
                        inputViewModel.showPicker = true
                    }
                )
            }
            .onChange(of: messages) { _ in
                scrollToBottom()
            }
            if viewModel.showAttachmentsView {
                let attachments = messages.flatMap { $0.attachments }
                let index = attachments.firstIndex { $0.id == viewModel.attachmentsFullscreenState.showFullscreen.value?.id }
                AttachmentsPages(
                    viewModel: AttachmentsPagesViewModel(
                        attachments: attachments,
                        index: index ?? 0
                    ),
                    onClose: {
                        viewModel.attachmentsFullscreenState.showFullscreen.value = nil
                    }
                )
            }
        }
        .onAppear {
            inputViewModel.didSendMessage = { [self] value in
                self.didSendMessage(value)
                self.scrollToBottom() // TODO: Make sure have no retain cycle
            }
        }
        .sheet(isPresented: $inputViewModel.showPicker) {
            AttachmentsEditor(viewModel: inputViewModel)
                .presentationDetents([.medium, .large])
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
                Message(id: 0, user: .steve, text: "Text 1"),
                Message(id: 1, user: .tim),
                Message(id: 5, user: .steve, attachments: [
                    ImageAttachment(url: URL(string: "https://picsum.photos/200/300")!)
                ]),
                Message(id: 6, user: .tim, text: "Text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text text"),
            ],
            didSendMessage: handleSendMessage
        )
    }
    
    static func handleSendMessage(message: DraftMessage) {
        print(message)
    }
}
