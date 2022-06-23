//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import Introspect
import AssetsPicker

public struct ChatView: View {
    public var messages: [Message]
    public var didSendMessage: (DraftMessage) -> Void

    @State private var scrollView: UIScrollView?
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    public init(messages: [Message], didSendMessage: @escaping (DraftMessage) -> Void) {
        self.messages = messages
        self.didSendMessage = didSendMessage
    }

    public var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message) { attachment in
                            viewModel.fullscreenAttachmentItem = attachment
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
                .environmentObject(globalFocusState)
            }
            .onChange(of: messages) { _ in
                scrollToBottom()
            }
            if viewModel.fullscreenAttachmentItem != nil {
                let attachments = messages.flatMap { $0.attachments }
                let index = attachments.firstIndex { $0.id == viewModel.fullscreenAttachmentItem?.id }
                AttachmentsPages(
                    viewModel: AttachmentsPagesViewModel(
                        attachments: attachments,
                        index: index ?? 0
                    ),
                    onClose: {
                        viewModel.fullscreenAttachmentItem = nil
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
                .environmentObject(globalFocusState)
        }
        .onChange(of: inputViewModel.showPicker) {
            if $0 {
                globalFocusState.focus = nil
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        globalFocusState.focus = nil
                    }
                    .tint(Color.blue)
                }
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
