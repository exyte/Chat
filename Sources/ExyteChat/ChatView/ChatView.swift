//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import FloatingButton
import SwiftUIIntrospect
import ExyteMediaPicker

public typealias MediaPickerParameters = SelectionParamsHolder

public enum ChatType {
    case chat // input view and the latest message at the bottom
    case comments // input view and the latest message on top
}

public struct ChatView<MessageContent: View, InputViewContent: View>: View {

    /// To build a custom message view use the following parameters passed by this closure:
    /// - message containing user, attachments, etc.
    /// - position of message in its continuous group of messages from the same user
    /// - pass attachment to this closure to use ChatView's fullscreen media viewer
    public typealias MessageBuilderClosure = ((Message, PositionInGroup, @escaping (Attachment) -> Void) -> MessageContent)

    /// To build a custom input view use the following parameters passed by this closure:
    /// - binding to the text in input view
    /// - InputViewAttachments to store the attachments from external pickers
    /// - Current input view state
    /// - .message for main input view mode and .signature for input view in media picker mode
    /// - closure to pass user interaction, .recordAudioTap for example
    /// - dismiss keyboard closure
    public typealias InputViewBuilderClosure = ((
        Binding<String>, InputViewAttachments, InputViewState, InputViewStyle, @escaping (InputViewAction) -> Void, ()->()) -> InputViewContent)

    /// User and MessageId
    public typealias TapAvatarClosure = (User, String) -> ()

    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.chatTheme) private var theme
    @Environment(\.mediaPickerTheme) private var pickerTheme

    // MARK: - Parameters

    private let sections: [MessagesSection]
    private let ids: [String]
    private let didSendMessage: (DraftMessage) -> Void

    // MARK: - View builders

    /// provide custom message view builder
    var messageBuilder: MessageBuilderClosure? = nil

    /// provide custom input view builder
    var inputViewBuilder: InputViewBuilderClosure? = nil

    // MARK: - Customization

    var type: ChatType = .chat
    var showDateHeaders: Bool = true
    var avatarSize: CGFloat = 32
    var messageUseMarkdown: Bool = false
    var showMessageMenuOnLongPress: Bool = true
    var showNetworkConnectionProblem: Bool = false
    var tapAvatarClosure: TapAvatarClosure?
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var orientationHandler: MediaPickerOrientationHandler = {_ in}
    var chatTitle: String?
    var showMessageTimeView = true
    var messageFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var availablelInput: AvailableInputType = .full

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()
    @StateObject private var paginationState = PaginationState()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var keyboardState = KeyboardState()

    @State private var inputFieldId = UUID()

    @State private var isScrolledToBottom: Bool = true
    @State private var shouldScrollToTop: () -> () = {}

    @State private var isShowingMenu = false
    @State private var needsScrollView = false
    @State private var readyToShowScrollView = false
    @State private var menuButtonsSize: CGSize = .zero
    @State private var cellFrames = [String: CGRect]()
    @State private var menuCellPosition: CGPoint = .zero
    @State private var menuBgOpacity: CGFloat = 0
    @State private var menuCellOpacity: CGFloat = 0
    @State private var menuScrollView: UIScrollView?

    public init(messages: [Message],
                didSendMessage: @escaping (DraftMessage) -> Void,
                messageBuilder: @escaping MessageBuilderClosure,
                inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.inputViewBuilder = inputViewBuilder
    }

    public var body: some View {
        VStack {
            if showNetworkConnectionProblem, !networkMonitor.isConnected {
                waitingForNetwork
            }

            switch type {
            case .chat:
                ZStack(alignment: .bottomTrailing) {
                    list

                    if !isScrolledToBottom {
                        Button {
                            NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                        } label: {
                            theme.images.scrollToBottom
                                .frame(width: 40, height: 40)
                                .circleBackground(theme.colors.friendMessage)
                        }
                        .padding(8)
                    }
                }

                inputView

            case .comments:
                inputView
                list
            }

        }
        .background(theme.colors.mainBackground)
        .fullScreenCover(isPresented: $viewModel.fullscreenAttachmentPresented) {
            let attachments = sections.flatMap { section in section.rows.flatMap { $0.message.attachments } }
            let index = attachments.firstIndex { $0.id == viewModel.fullscreenAttachmentItem?.id }

            GeometryReader { g in
                FullscreenMediaPages(
                    viewModel: FullscreenMediaPagesViewModel(
                        attachments: attachments,
                        index: index ?? 0
                    ),
                    safeAreaInsets: g.safeAreaInsets,
                    onClose: { [weak viewModel] in
                        viewModel?.dismissAttachmentFullScreen()
                    }
                )
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $inputViewModel.showPicker) {
            AttachmentsEditor(inputViewModel: inputViewModel, inputViewBuilder: inputViewBuilder, chatTitle: chatTitle, messageUseMarkdown: messageUseMarkdown, orientationHandler: orientationHandler, mediaPickerSelectionParameters: mediaPickerSelectionParameters, availableInput: availablelInput)
                .environmentObject(globalFocusState)
        }
        .onChange(of: inputViewModel.showPicker) {
            if $0 {
                globalFocusState.focus = nil
            }
        }
        .environmentObject(keyboardState)
    }

    var waitingForNetwork: some View {
        VStack {
            Rectangle()
                .foregroundColor(.black.opacity(0.12))
                .frame(height: 1)
            HStack {
                Spacer()
                Image("waiting", bundle: .current)
                Text("Waiting for network")
                Spacer()
            }
            .padding(.top, 6)
            Rectangle()
                .foregroundColor(.black.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    var list: some View {
        UIList(viewModel: viewModel,
               paginationState: paginationState,
               isScrolledToBottom: $isScrolledToBottom,
               shouldScrollToTop: $shouldScrollToTop,
               messageBuilder: messageBuilder, 
               type: type,
               showDateHeaders: showDateHeaders,
               avatarSize: avatarSize,
               showMessageMenuOnLongPress: showMessageMenuOnLongPress,
               tapAvatarClosure: tapAvatarClosure,
               messageUseMarkdown: messageUseMarkdown,
               showMessageTimeView: showMessageTimeView,
               messageFont: messageFont,
               sections: sections,
               ids: ids
        )
        .onStatusBarTap {
            shouldScrollToTop()
        }
        .transparentNonAnimatingFullScreenCover(item: $viewModel.messageMenuRow) {
            if let row = viewModel.messageMenuRow {
                ZStack(alignment: .topLeading) {
                    Color.white
                        .opacity(menuBgOpacity)
                        .ignoresSafeArea(.all)

                    if needsScrollView {
                        ScrollView {
                            messageMenu(row)
                        }
                        .introspect(.scrollView, on: .iOS(.v16, .v17)) { scrollView in
                            DispatchQueue.main.async {
                                self.menuScrollView = scrollView
                            }
                        }
                        .opacity(readyToShowScrollView ? 1 : 0)
                    }
                    if !needsScrollView || !readyToShowScrollView {
                        messageMenu(row)
                            .position(menuCellPosition)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        if let frame = cellFrames[row.id] {
                            showMessageMenu(frame)
                        }
                    }
                }
                .onTapGesture {
                    hideMessageMenu()
                }
            }
        }
        .onPreferenceChange(MessageMenuPreferenceKey.self) {
            self.cellFrames = $0
        }
        .onTapGesture {
            globalFocusState.focus = nil
        }
        .onAppear {
            viewModel.didSendMessage = didSendMessage
            inputViewModel.didSendMessage = { value in
                didSendMessage(value)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                }
            }
        }
    }

    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder($inputViewModel.attachments.text, inputViewModel.attachments, inputViewModel.state, .message, inputViewModel.inputViewAction()) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: inputFieldId,
                    style: .message,
                    availableInput: availablelInput,
                    messageUseMarkdown: messageUseMarkdown
                )
            }
        }
        .environmentObject(globalFocusState)
        .onAppear(perform: inputViewModel.onStart)
        .onDisappear(perform: inputViewModel.onStop)
    }

    func messageMenu(_ row: MessageRow) -> some View {
        MessageMenu(
            isShowingMenu: $isShowingMenu,
            menuButtonsSize: $menuButtonsSize,
            alignment: row.message.user.isCurrentUser ? .right : .left,
            leadingPadding: avatarSize + MessageView.horizontalAvatarPadding * 2,
            trailingPadding: MessageView.statusViewSize + MessageView.horizontalStatusPadding) {
                ChatMessageView(viewModel: viewModel, messageBuilder: messageBuilder, row: row, chatType: type, avatarSize: avatarSize, tapAvatarClosure: nil, messageUseMarkdown: messageUseMarkdown, isDisplayingMessageMenu: true, showMessageTimeView: showMessageTimeView, messageFont: messageFont)
                    .onTapGesture {
                        hideMessageMenu()
                    }
            } onAction: { action in
                onMessageMenuAction(row: row, action: action)
            }
            .frame(height: menuButtonsSize.height + (cellFrames[row.id]?.height ?? 0), alignment: .top)
            .opacity(menuCellOpacity)
    }

    func showMessageMenu(_ cellFrame: CGRect) {
        DispatchQueue.main.async {
            let wholeMenuHeight = menuButtonsSize.height + cellFrame.height
            let needsScrollTemp = wholeMenuHeight > UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom

            menuCellPosition = CGPoint(x: cellFrame.midX, y: cellFrame.minY + wholeMenuHeight/2 - safeAreaInsets.top)
            menuCellOpacity = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                var finalCellPosition = menuCellPosition
                if needsScrollTemp ||
                    cellFrame.minY + wholeMenuHeight + safeAreaInsets.bottom > UIScreen.main.bounds.height {

                    finalCellPosition = CGPoint(x: cellFrame.midX, y: UIScreen.main.bounds.height - wholeMenuHeight/2 - safeAreaInsets.top - safeAreaInsets.bottom
                    )
                }

                withAnimation(.linear(duration: 0.1)) {
                    menuBgOpacity = 0.9
                    menuCellPosition = finalCellPosition
                    isShowingMenu = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                needsScrollView = needsScrollTemp
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                readyToShowScrollView = true
                if let menuScrollView = menuScrollView {
                    menuScrollView.contentOffset = CGPoint(x: 0, y: menuScrollView.contentSize.height - menuScrollView.frame.height + safeAreaInsets.bottom)
                }
            }
        }
    }

    func hideMessageMenu() {
        menuScrollView = nil
        withAnimation(.linear(duration: 0.1)) {
            menuCellOpacity = 0
            menuBgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.messageMenuRow = nil
            isShowingMenu = false
            needsScrollView = false
            readyToShowScrollView = false
        }
    }

    func onMessageMenuAction(row: MessageRow, action: MessageMenuAction) {
        hideMessageMenu()

        switch action {
        case .reply:
            inputViewModel.attachments.replyMessage = row.message.toReplyMessage()
            globalFocusState.focus = .uuid(inputFieldId)
        }
    }
}

private extension ChatView {
    static func mapMessages(_ messages: [Message]) -> [MessagesSection] {
        guard messages.hasUniqueIDs() else {
            fatalError("Messages can not have duplicate ids, please make sure every message gets a unique id")
        }
        let dates = Set(messages.map({ $0.createdAt.startOfDay() }))
            .sorted()
            .reversed()
        var result: [MessagesSection] = []

        for date in dates {
            let section = MessagesSection(
                date: date,
                rows: wrapMessages(messages.filter({ $0.createdAt.isSameDay(date) }))
            )
            result.append(section)
        }

        return result
    }

    static func wrapMessages(_ messages: [Message]) -> [MessageRow] {
        messages
            .enumerated()
            .map {
                let nextMessageExists = messages[safe: $0.offset + 1] != nil
                let nextMessageIsSameUser = messages[safe: $0.offset + 1]?.user.id == $0.element.user.id
                let prevMessageIsSameUser = messages[safe: $0.offset - 1]?.user.id == $0.element.user.id

                let position: PositionInGroup
                if nextMessageExists, nextMessageIsSameUser, prevMessageIsSameUser {
                    position = .middle
                } else if !nextMessageExists || !nextMessageIsSameUser, !prevMessageIsSameUser {
                    position = .single
                } else if nextMessageExists, nextMessageIsSameUser {
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

    func chatType(_ type: ChatType) -> ChatView {
        var view = self
        view.type = type
        return view
    }

    func showDateHeaders(showDateHeaders: Bool) -> ChatView {
        var view = self
        view.showDateHeaders = showDateHeaders
        return view
    }

    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }

    func messageUseMarkdown(messageUseMarkdown: Bool) -> ChatView {
        var view = self
        view.messageUseMarkdown = messageUseMarkdown
        return view
    }

    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.showMessageMenuOnLongPress = show
        return view
    }

    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.showNetworkConnectionProblem = show
        return view
    }

    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.tapAvatarClosure = closure
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = MediaPickerParameters()
        view.mediaPickerSelectionParameters?.selectionLimit = assetsPickerLimit
        return view
    }

    func setMediaPickerSelectionParameters(_ params: MediaPickerParameters) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = params
        return view
    }

    func orientationHandler(orientationHandler: @escaping MediaPickerOrientationHandler) -> ChatView {
        var view = self
        view.orientationHandler = orientationHandler
        return view
    }

    /// when user scrolls to `offset`-th meassage from the end, call the handler function, so user can load more messages
    func enableLoadMore(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view._paginationState = StateObject(wrappedValue: PaginationState(onEvent: handler, offset: offset))
        return view
    }

    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        var view = self
        view.chatTitle = title
        return view.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }

    func showMessageTimeView(_ isShow: Bool) -> ChatView {
        var view = self
        view.showMessageTimeView = isShow
        return view
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageFont = font
        return view
    }

    func setAvailableInput(_ type: AvailableInputType) -> ChatView {
        var view = self
        view.availablelInput = type
        return view
    }
}

public extension ChatView where MessageContent == EmptyView {

    init(messages: [Message],
         didSendMessage: @escaping (DraftMessage) -> Void,
         inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self.inputViewBuilder = inputViewBuilder
    }
}

public extension ChatView where InputViewContent == EmptyView {

    init(messages: [Message],
         didSendMessage: @escaping (DraftMessage) -> Void,
         messageBuilder: @escaping MessageBuilderClosure) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {

    init(messages: [Message],
         didSendMessage: @escaping (DraftMessage) -> Void) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
    }
}

