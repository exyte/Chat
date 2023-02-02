//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

private let lastMessageAnchorKey = "LastMessageAnchorKey"

public extension ChatView where MessageContent == EmptyView {

    init(messages: [Message],
         didSendMessage: @escaping (DraftMessage) -> Void) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
    }
}

public struct ChatView<MessageContent: View>: View {

    /// To build a custom message view use the following parameters:
    /// - message containing all you need user, attachments, etc.
    /// - position of message in its group
    /// - pass attachment to this closure to use ChatView's fullscreen media viewer
    public typealias MessageBuilderClosure = ((Message, PositionInGroup, @escaping (any Attachment) -> Void) -> MessageContent)

    @Environment(\.chatTheme) private var theme

    let didSendMessage: (DraftMessage) -> Void

    /// provide custom message view builder
    var messageBuilder: MessageBuilderClosure? = nil

    var avatarSize: CGFloat = 32
    var assetsPickerLimit: Int = 10
    var messageUseMarkdown: Bool = false

    private let sections: [MessagesSection]
    private let ids: [String]

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()

    @StateObject var paginationState = PaginationState()

    public init(messages: [Message],
                didSendMessage: @escaping (DraftMessage) -> Void,
                messageBuilder: @escaping MessageBuilderClosure) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
    }

    public var body: some View {
        VStack(spacing: 0) {
            list

            InputView(
                text: $inputViewModel.text,
                style: .message,
                canSend: inputViewModel.canSend,
                onAction: {
                    switch $0 {
                    case .attach, .photo:
                        inputViewModel.showPicker = true
                    case .send:
                        inputViewModel.send()
                    }
                }
            )
            .environmentObject(globalFocusState)
            .onAppear(perform: inputViewModel.onStart)
            .onDisappear(perform: inputViewModel.onStop)
        }
        .fullScreenCover(isPresented: $viewModel.fullscreenAttachmentPresented) {
            let attachments = sections.flatMap { section in section.rows.flatMap { $0.message.attachments } }
            let index = attachments.firstIndex { $0.id == viewModel.fullscreenAttachmentItem?.id }

            AttachmentsPages(
                viewModel: AttachmentsPagesViewModel(
                    attachments: attachments,
                    index: index ?? 0
                ),
                onClose: { [weak viewModel] in
                    viewModel?.dismissAttachmentFullScreen()
                }
            )
        }
        .sheet(isPresented: $inputViewModel.showPicker) {
            AttachmentsEditor(viewModel: inputViewModel, assetsPickerLimit: assetsPickerLimit)
                .background(theme.colors.mediaPickerBackground)
                .presentationDetents([.medium, .large])
                .environmentObject(globalFocusState)
        }
        .onChange(of: inputViewModel.showPicker) {
            if $0 {
                globalFocusState.focus = nil
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }

    var list: some View {
        ScrollViewReader { proxy in
            List(sections, id: \.date) { section in
                if sections.first?.date == section.date {
                    EmptyView().id(lastMessageAnchorKey)
                }
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
    }

    func buildSection(_ section: MessagesSection) -> some View {
        Section {
            ForEach(section.rows, id: \.message.id) { row in
                Group {
                    if let messageBuilder = messageBuilder {
                        messageBuilder(row.message, row.positionInGroup) { attachment in
                            viewModel.presentAttachmentFullScreen(attachment)
                        }
                    } else {
                        MessageView(
                            message: row.message,
                            showAvatar: row.positionInGroup == .last,
                            avatarSize: avatarSize,
                            messageUseMarkdown: messageUseMarkdown) { attachment in
                                viewModel.presentAttachmentFullScreen(attachment)
                            } onRetry: {
                                didSendMessage(row.message.toDraft())
                            }
                    }
                }
                .id(row.message.id)
                .rotationEffect(Angle(degrees: 180))
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .onAppear {
                    paginationState.handle(row.message, ids: ids)
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
                rows: wrapMessages(messages.filter({ $0.createdAt.isSameDay(date) }))
            )
            result.append(section)
        }

        return result
    }

    static func wrapMessages(_ messages: [Message]) -> [MessageRow] {
        return messages
            .enumerated()
            .map {
                let nextMessageIsSameUser = messages[safe: $0.offset + 1]?.user.id == $0.element.user.id
                let prevMessageIsSameUser = messages[safe: $0.offset - 1]?.user.id == $0.element.user.id

                let position: PositionInGroup
                if nextMessageIsSameUser, prevMessageIsSameUser {
                    position = .middle
                } else if !nextMessageIsSameUser, !nextMessageIsSameUser {
                    position = .single
                } else if nextMessageIsSameUser {
                    position = .first
                } else {
                    position = .last
                }

                return MessageRow(message: $0.element, positionInGroup: position)
            }
            .reversed()
    }
}

public extension ChatView {

    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.assetsPickerLimit = assetsPickerLimit
        return view
    }

    func messageUseMarkdown(messageUseMarkdown: Bool) -> ChatView {
        var view = self
        view.messageUseMarkdown = messageUseMarkdown
        return view
    }

    /// when user scrolls to `offset`-th meassage from the end, call the handler function, so user can load more messages
    func enableLoadMore(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }

    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        self.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }
}
