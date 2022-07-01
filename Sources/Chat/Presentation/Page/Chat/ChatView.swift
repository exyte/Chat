//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import AssetsPicker

public struct ChatView: View {
    @Binding public var messages: [Message]
    public var didSendMessage: (DraftMessage) -> Void

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    @StateObject var paginationState = PaginationState()

    public init(messages: Binding<[Message]>,
                didSendMessage: @escaping (DraftMessage) -> Void) {
        self._messages = messages
        self.didSendMessage = didSendMessage
    }

    public var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { proxy in
                    List(messages.reversed(), id: \.id) { message in
                        MessageView(message: message) { attachment in
                            viewModel.fullscreenAttachmentItem = attachment
                        } onRetry: {
                            didSendMessage(message.toDraft())
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .rotationEffect(Angle(degrees: 180))
                        .id(message.id)
                        .onAppear {
                            paginationState.handle(message, in: messages)
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .rotationEffect(Angle(degrees: 180))
                    .onAppear {
                        inputViewModel.didSendMessage = { value in
                            didSendMessage(value)
                            if let id = messages.last?.id {
                                proxy.scrollTo(id)
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

public extension ChatView {
    func chatEnablePagination(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }
}
