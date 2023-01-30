//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

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
        VStack(spacing: 0) {
            list

            InputView(
                style: .message,
                text: $inputViewModel.text,
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
            AttachmentsEditor(viewModel: inputViewModel)
                .background(Color(hex: "1F1F1F"))
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
                    MessageView(message: row.message, hideAvatar: row.nextMessageIsSameUser) { attachment in
                        viewModel.presentAttachmentFullScreen(attachment)
                    } onRetry: {
                        didSendMessage(row.message.toDraft())
                    }
                    .id(row.message.id)
                    .rotationEffect(Angle(degrees: 180))
                }
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
                return MessageRow(
                    message: $0.element,
                    nextMessageIsSameUser: nextMessageIsSameUser
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
