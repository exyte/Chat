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

struct MessagesSection: Equatable {
    let date: String
    let messages: [WrappedMessage]
}

private let lastMessageAnchorKey = "LastMessageAnchorKey"

public struct ChatView: View {
    let didSendMessage: (DraftMessage) -> Void

    private let sections: [MessagesSection]
    private let ids: [String]

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    @StateObject var paginationState = PaginationState()

    public init(messages: [Message],
                didSendMessage: @escaping (DraftMessage) -> Void) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
    }

    public var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { proxy in
                    List(sections, id: \.date) { section in
                        buildSection(section)
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .rotationEffect(Angle(degrees: 180))
                    .onAppear {
                        inputViewModel.didSendMessage = { value in
                            didSendMessage(value)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo(lastMessageAnchorKey)
                                }
                            }
                        }
                    }
                }
                .animation(.default, value: sections)

                InputView(
                    viewModel: inputViewModel,
                    onTapAttach: {
                        inputViewModel.showPicker = true
                    }
                )
                .environmentObject(globalFocusState)
            }
            if viewModel.fullscreenAttachmentItem != nil {
                // TODO: Remove double flatMap for attachments
                let attachments = sections.flatMap { $0.messages.flatMap { $0.message.attachments } }
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
                .assetsPickerCompletion { _ in }
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

    var list: some View {
        ScrollViewReader { proxy in
            List(sections, id: \.date) { section in
                buildSection(section)
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
        .animation(.default, value: sections)
    }

    func buildSection(_ section: MessagesSection) -> some View {
        Section {
            ForEach(section.messages, id: \.message.id) { wrappedMessage in
                Group {
                    if wrappedMessage.isFirstMessage {
                        EmptyView().id("FirstMessageAnchor")
                    }
                    MessageView(message: wrappedMessage.message, hideAvatar: wrappedMessage.nextMessageIsSameUser) { attachment in
                        viewModel.fullscreenAttachmentItem = attachment
                    } onRetry: {
                        didSendMessage(wrappedMessage.message.toDraft())
                    }
                    .id(wrappedMessage.message.id)
                    .rotationEffect(Angle(degrees: 180))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .onAppear {
                    paginationState.handle(wrappedMessage.message, ids: ids)
                }
            }
        } footer: {
            Text(section.date)
            .frame(maxWidth: .infinity)
            .rotationEffect(Angle(degrees: 180))
        }
        .listSectionSeparator(.hidden)
    }
}

private extension ChatView {
    static func mapMessages(_ messages: [Message]) -> [MessagesSection] {
        let dates = Set(messages.map({ $0.createdAt.startOfDay() }))
            .sorted()
            .reversed()
        var result: [MessagesSection] = []

        for date in dates {
            let section = MessagesSection(
                date: date.formatted(date: .complete, time: .omitted),
                messages: wrapMessages(messages.filter({ $0.createdAt.isSame(date) }))
            )
            result.append(section)
        }

        return result
    }

    static func wrapMessages(_ messages: [Message]) -> [WrappedMessage] {
        return messages
            .enumerated()
            .map {
                let nextMessageIsSameUser = messages[safe: $0.offset + 1]?.user.id == $0.element.user.id
                return WrappedMessage(
                    message: $0.element,
                    nextMessageIsSameUser: nextMessageIsSameUser,
                    isFirstMessage: $0.offset == (messages.count - 1)
                )
            }
            .reversed()
    }
}

public extension ChatView {
    func chatEnablePagination(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }
}
