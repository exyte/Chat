//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import AssetsPicker

struct WrappedMessage: Equatable {
    let message: Message
    let nextMessageIsSameUser: Bool
    let isFirstMessage: Bool
}

public struct ChatView: View {
    @Binding public var originalMessages: [Message]
    @State private var messages: [WrappedMessage] = []
    public var didSendMessage: (DraftMessage) -> Void

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    @StateObject var paginationState = PaginationState()

    public init(messages: Binding<[Message]>,
                didSendMessage: @escaping (DraftMessage) -> Void) {
        self._originalMessages = messages
        self.didSendMessage = didSendMessage
    }

    public var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { proxy in
                    List(messages, id: \.message.id) { box in
                        Group {
                            if box.isFirstMessage {
                                EmptyView().id("FirstMessageAnchor")
                            }
                            MessageView(message: box.message, hideAvatar: box.nextMessageIsSameUser) { attachment in
                                viewModel.fullscreenAttachmentItem = attachment
                            } onRetry: {
                                didSendMessage(box.message.toDraft())
                            }
                            .id(box.message.id)
                            .rotationEffect(Angle(degrees: 180))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .onAppear {
                            paginationState.handle(box.message, in: originalMessages)
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .rotationEffect(Angle(degrees: 180))
                    .onAppear {
                        inputViewModel.didSendMessage = { value in
                            didSendMessage(value)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo("FirstMessageAnchor")
                                }
                            }
                        }
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
                let attachments = originalMessages.flatMap { $0.attachments }
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
        .onChange(of: originalMessages) { newValue in
            self.messages = newValue.enumerated()
                .map {
                    let nextMessageIsSameUser = newValue[safe: $0.offset + 1]?.user.id == $0.element.user.id
                    return WrappedMessage(
                        message: $0.element,
                        nextMessageIsSameUser: nextMessageIsSameUser,
                        isFirstMessage: $0.offset == (newValue.count - 1)
                    )
                }
                .reversed()
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

public extension ChatView {
    func chatEnablePagination(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }
}
