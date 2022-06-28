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
    @Binding public var messages: [Message]
    public var didSendMessage: (DraftMessage) -> Void

    @State private var scrollView: UIScrollView?
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    @Environment(\.chatPagination) private var paginationState

    public init(messages: Binding<[Message]>,
                didSendMessage: @escaping (DraftMessage) -> Void) {
        self._messages = messages
        self.didSendMessage = didSendMessage
    }

    public var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages.reversed(), id: \.id) { message in
                                MessageView(message: message) { attachment in
                                    viewModel.fullscreenAttachmentItem = attachment
                                }
                                .rotationEffect(Angle(degrees: 180))
                                .id(message.id)
                                .onAppear {
                                    paginationState.handle(message, in: messages)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .rotationEffect(Angle(degrees: 180))
                    .introspectScrollView { scrollView in
                        self.scrollView = scrollView
                    }
                }
                .animation(.default, value: messages)

                InputView(
                    viewModel: inputViewModel,
                    onTapAttach: {
                        inputViewModel.showPicker = true
                    }
                )
                .environmentObject(globalFocusState)
            }
            if viewModel.fullscreenAttachmentItem != nil {
                let attachments = messages.flatMap { $0.attachments }
                let index = attachments.firstIndex { $0.id == viewModel.fullscreenAttachmentItem?.id }
                AttachmentsPages(
                    viewModel: AttachmentsPagesViewModel(
                        attachments: attachments,
                        index: index ?? 0
                    ),
                    onClose: { [weak viewModel] in
                        viewModel?.fullscreenAttachmentItem = nil
                    }
                )
            }
        }
        .onAppear {
            inputViewModel.didSendMessage = { [self] value in
                self.didSendMessage(value)
                self.scrollToLastMessage() // TODO: Make sure have no retain cycle
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
    func scrollToLastMessage() {
        if let scrollView = scrollView {
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
}
