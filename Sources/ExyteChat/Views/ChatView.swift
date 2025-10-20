//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import GiphyUISDK
import ExyteMediaPicker

public typealias MediaPickerParameters = SelectionParamsHolder

public enum ChatType: CaseIterable, Sendable {
    case conversation // the latest message is at the bottom, new messages appear from the bottom
    case comments // the latest message is at the top, new messages appear from the top
}

public enum ReplyMode: CaseIterable, Sendable {
    case quote // when replying to message A, new message will appear as the newest message, quoting message A in its body
    case answer // when replying to message A, new message with appear direclty below message A as a separate cell without duplicating message A in its body
}

public struct ChatView<MessageContent: View, InputViewContent: View, MenuAction: MessageMenuAction>: View {
    
    /// To build a custom message view use the following parameters passed by this closure:
    /// - message containing user, attachments, etc.
    /// - position of message in its continuous group of messages from the same user
    /// - position of message in the section of messages from that day
    /// - position of message in its continuous group of comments (only works for .answer ReplyMode, nil for .quote mode)
    /// - closure to show message context menu
    /// - closure to pass user interaction, .reply for example
    /// - pass attachment to this closure to use ChatView's fullscreen media viewer
    public typealias MessageBuilderClosure = ((
        _ message: Message,
        _ positionInGroup: PositionInUserGroup,
        _ positionInMessagesSection: PositionInMessagesSection,
        _ positionInCommentsGroup: CommentsPosition?,
        _ showContextMenuClosure: @escaping () -> Void,
        _ messageActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void,
        _ showAttachmentClosure: @escaping (Attachment) -> Void
    ) -> MessageContent)
    
    /// To build a custom input view use the following parameters passed by this closure:
    /// - binding to the text in input view
    /// - InputViewAttachments to store the attachments from external pickers
    /// - current input view state: .message for main input view mode and .signature for input view in media picker mode
    /// - closure to pass user interaction, .recordAudioTap for example
    /// - dismiss keyboard closure
    public typealias InputViewBuilderClosure = (
        _ text: Binding<String>,
        _ attachments: InputViewAttachments,
        _ inputViewState: InputViewState,
        _ inputViewStyle: InputViewStyle,
        _ inputViewActionClosure: @escaping (InputViewAction) -> Void,
        _ dismissKeyboardClosure: ()->()
    ) -> InputViewContent
    
    /// To define custom message menu actions declare an enum conforming to MessageMenuAction. The library will show your custom menu options on long tap on message. Once the action is selected the following callback will be called:
    /// - action selected by the user from the menu. NOTE: when declaring this variable, specify its type (your custom descendant of MessageMenuAction) explicitly
    /// - a closure taking a case of default implementation of MessageMenuAction which provides simple actions handlers; you call this closure passing the selected message and choosing one of the default actions if you need them; or you can write a custom implementation for all your actions, in that case just ignore this closure
    /// - message for which the menu is displayed
    /// When implementing your own MessageMenuActionClosure, write a switch statement passing through all the cases of your MessageMenuAction, inside each case write your own action handler, or call the default one. NOTE: not all default actions work out of the box - e.g. for .edit you'll still need to provide a closure to save the edited text on your BE. Please see CommentsExampleView in ChatExample project for MessageMenuActionClosure usage example.
    public typealias MessageMenuActionClosure = (
        _ selectedMenuAction: MenuAction,
        _ defaultActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void,
        _ message: Message
    ) -> Void
    
    /// User and MessageId
    public typealias TapAvatarClosure = (User, String) -> ()
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.chatTheme) private var theme
    @Environment(\.giphyConfig) private var giphyConfig
    
    // MARK: - Parameters
    
    let type: ChatType
    let sections: [MessagesSection]
    let ids: [String]
    let didSendMessage: (DraftMessage) -> Void
    var reactionDelegate: ReactionDelegate?

    // MARK: - View builders
    
    /// provide custom message view builder
    var messageBuilder: MessageBuilderClosure? = nil
    
    /// provide custom input view builder
    var inputViewBuilder: InputViewBuilderClosure? = nil
    
    /// message menu customization: create enum complying to MessageMenuAction and pass a closure processing your enum cases
    var messageMenuAction: MessageMenuActionClosure?
    
    /// content to display in between the chat list view and the input view
    var betweenListAndInputViewBuilder: (()->AnyView)?
    
    /// a header for the whole chat, which will scroll together with all the messages and headers
    var mainHeaderBuilder: (()->AnyView)?
    
    /// date section header builder
    var headerBuilder: ((Date)->AnyView)?
    
    /// provide strings for the chat view, these can be localized in the Localizable.strings files
    var localization: ChatLocalization = createLocalization()
    
    // MARK: - Customization
    
    var isListAboveInputView: Bool = true
    var showDateHeaders: Bool = true
    var isScrollEnabled: Bool = true
    var avatarSize: CGFloat = 32
    var messageStyler: (String) -> AttributedString = AttributedString.init
    var shouldShowLinkPreview: (URL) -> Bool = { _ in true }
    var showMessageMenuOnLongPress: Bool = true
    var messageMenuAnimationDuration: Double = 0.3
    var showNetworkConnectionProblem: Bool = false
    var tapAvatarClosure: TapAvatarClosure?
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var orientationHandler: MediaPickerOrientationHandler = {_ in}
    var chatTitle: String?
    var paginationHandler: PaginationHandler?
    var showMessageTimeView = true
    var messageLinkPreviewLimit = 8
    var messageFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var availableInputs: [AvailableInputType] = [.text, .audio, .giphy, .media]
    var recorderSettings: RecorderSettings = RecorderSettings()
    var listSwipeActions: ListSwipeActions = ListSwipeActions()
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none
    
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var keyboardState = KeyboardState()
    
    @State private var isScrolledToBottom: Bool = true
    @State private var shouldScrollToTop: () -> () = {}

    /// Used to prevent the MainView from responding to keyboard changes while the Menu is active
    @State private var isShowingMenu = false

    @State private var tableContentHeight: CGFloat = 0
    @State private var inputViewSize = CGSize.zero
    @State private var cellFrames = [String: CGRect]()

    @State private var giphyConfigured = false
    @State private var selectedMedia: GPHMedia? = nil
    
    public init(messages: [Message],
                chatType: ChatType = .conversation,
                replyMode: ReplyMode = .quote,
                didSendMessage: @escaping (DraftMessage) -> Void,
                reactionDelegate: ReactionDelegate? = nil,
                messageBuilder: @escaping MessageBuilderClosure,
                inputViewBuilder: @escaping InputViewBuilderClosure,
                messageMenuAction: MessageMenuActionClosure?,
                localization: ChatLocalization) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.inputViewBuilder = inputViewBuilder
        self.messageMenuAction = messageMenuAction
        self.localization = localization
    }
    
    public var body: some View {
        mainView
            .background(chatBackground())
            .environmentObject(keyboardState)
        
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
            .onAppear() {
                if isGiphyAvailable() {
                    if let giphyKey = giphyConfig.giphyKey {
                        if !giphyConfigured {
                            giphyConfigured = true
                            Giphy.configure(apiKey: giphyKey)
                        }
                    } else {
                        print("WARNING: giphy key not provided, please pass a key using giphyConfig")
                    }
                }
            }
            .onChange(of: selectedMedia) {
                if let giphyMedia = selectedMedia {
                    inputViewModel.attachments.giphyMedia = giphyMedia
                    inputViewModel.send()
                }
            }
            .sheet(isPresented: $inputViewModel.showGiphyPicker) {
                if giphyConfig.giphyKey != nil {
                    GiphyEditorView(
                        giphyConfig: giphyConfig,
                        selectedMedia: $selectedMedia
                    )
                    .environmentObject(globalFocusState)
                } else {
                    Text("no giphy key found")
                }
            }
            .fullScreenCover(isPresented: $inputViewModel.showPicker) {
                AttachmentsEditor(
                    inputViewModel: inputViewModel,
                    inputViewBuilder: inputViewBuilder,
                    chatTitle: chatTitle,
                    messageStyler: messageStyler,
                    orientationHandler: orientationHandler,
                    mediaPickerSelectionParameters: mediaPickerSelectionParameters,
                    availableInputs: availableInputs,
                    localization: localization
                )
                .environmentObject(globalFocusState)
                .environmentObject(keyboardState)
            }
        
            .onChange(of: inputViewModel.showPicker) { _ , newValue in
                if newValue {
                    globalFocusState.focus = nil
                }
            }
            .onChange(of: inputViewModel.showGiphyPicker) { _ , newValue in
                if newValue {
                    globalFocusState.focus = nil
                }
            }
    }
    
    var mainView: some View {
        VStack {
            if showNetworkConnectionProblem, !networkMonitor.isConnected {
                waitingForNetwork
            }
            
            if isListAboveInputView {
                listWithButton
                if let builder = betweenListAndInputViewBuilder {
                    builder()
                }
                inputView
            } else {
                inputView
                if let builder = betweenListAndInputViewBuilder {
                    builder()
                }
                listWithButton
            }
        }
        // Used to prevent ChatView movement during Emoji Keyboard invocation
        .ignoresSafeArea(isShowingMenu ? .keyboard : [])
    }
    
    var waitingForNetwork: some View {
        VStack {
            Rectangle()
                .foregroundColor(theme.colors.mainText.opacity(0.12))
                .frame(height: 1)
            HStack {
                Spacer()
                Image("waiting", bundle: .current)
                Text(localization.waitingForNetwork)
                Spacer()
            }
            .padding(.top, 6)
            Rectangle()
                .foregroundColor(theme.colors.mainText.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    var listWithButton: some View {
        switch type {
        case .conversation:
            ZStack(alignment: .bottomTrailing) {
                list
                
                if !isScrolledToBottom {
                    Button {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    } label: {
                        theme.images.scrollToBottom
                            .frame(width: 40, height: 40)
                            .circleBackground(theme.colors.messageFriendBG)
                            .foregroundStyle(theme.colors.sendButtonBackground)
                            .shadow(color: .primary.opacity(0.1), radius: 2, y: 1)
                    }
                    .padding(.trailing, MessageView.horizontalScreenEdgePadding)
                    .padding(.bottom, 8)
                }
            }
            
        case .comments:
            list
        }
    }
    
    @ViewBuilder
    var list: some View {
        UIList(
            viewModel: viewModel,
            inputViewModel: inputViewModel,
            isScrolledToBottom: $isScrolledToBottom,
            shouldScrollToTop: $shouldScrollToTop,
            tableContentHeight: $tableContentHeight,
            messageBuilder: messageBuilder,
            mainHeaderBuilder: mainHeaderBuilder,
            headerBuilder: headerBuilder,
            inputView: inputView,
            type: type,
            showDateHeaders: showDateHeaders,
            isScrollEnabled: isScrollEnabled,
            avatarSize: avatarSize,
            showMessageMenuOnLongPress: showMessageMenuOnLongPress,
            tapAvatarClosure: tapAvatarClosure,
            paginationHandler: paginationHandler,
            messageStyler: messageStyler,
            shouldShowLinkPreview: shouldShowLinkPreview,
            showMessageTimeView: showMessageTimeView,
            messageLinkPreviewLimit: messageLinkPreviewLimit,
            messageFont: messageFont,
            sections: sections,
            ids: ids,
            listSwipeActions: listSwipeActions,
            keyboardDismissMode: keyboardDismissMode
        )
        .applyIf(!isScrollEnabled) {
            $0.frame(height: tableContentHeight)
        }
        .onStatusBarTap {
            shouldScrollToTop()
        }
        .transparentNonAnimatingFullScreenCover(item: $viewModel.messageMenuRow) {
            if let row = viewModel.messageMenuRow {
                messageMenu(row)
                    .onAppear(perform: showMessageMenu)
            }
            
        }
        .onPreferenceChange(MessageMenuPreferenceKey.self) { frames in
            DispatchQueue.main.async {
                self.cellFrames = frames
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                globalFocusState.focus = nil
            }
        )
        .onAppear {
            viewModel.didSendMessage = didSendMessage
            viewModel.inputViewModel = inputViewModel
            viewModel.globalFocusState = globalFocusState

            inputViewModel.didSendMessage = { value in
                Task { @MainActor in
                    didSendMessage(value)
                }
                if type == .conversation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    }
                }
            }
        }
    }

    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder($inputViewModel.text, inputViewModel.attachments, inputViewModel.state, .message, inputViewModel.inputViewAction()) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: viewModel.inputFieldId,
                    style: .message,
                    availableInputs: availableInputs,
                    messageStyler: messageStyler,
                    recorderSettings: recorderSettings,
                    localization: localization
                )
            }
        }
        .sizeGetter($inputViewSize)
        .environmentObject(globalFocusState)
        .onAppear(perform: inputViewModel.onStart)
        .onDisappear(perform: inputViewModel.onStop)
    }
    
    func messageMenu(_ row: MessageRow) -> some View {
        let cellFrame = cellFrames[row.id] ?? .zero

        return MessageMenu(
            viewModel: viewModel,
            isShowingMenu: $isShowingMenu,
            message: row.message,
            cellFrame: cellFrame,
            alignment: menuAlignment(row.message, chatType: type),
            positionInUserGroup: row.positionInUserGroup,
            leadingPadding: avatarSize + MessageView.horizontalAvatarPadding * 2,
            trailingPadding: MessageView.statusViewSize + MessageView.horizontalStatusPadding,
            font: messageFont,
            animationDuration: messageMenuAnimationDuration,
            onAction: menuActionClosure(row.message),
            reactionHandler: MessageMenu.ReactionConfig(
                delegate: reactionDelegate,
                didReact: reactionClosure(row.message)
            )
        ) {
            ChatMessageView(
                viewModel: viewModel, messageBuilder: messageBuilder, row: row, chatType: type,
                avatarSize: avatarSize, tapAvatarClosure: nil, messageStyler: messageStyler,
                shouldShowLinkPreview: shouldShowLinkPreview,
                isDisplayingMessageMenu: true, showMessageTimeView: showMessageTimeView,
                messageLinkPreviewLimit: messageLinkPreviewLimit, messageFont: messageFont
            )
            .onTapGesture {
                hideMessageMenu()
            }
        }
    }
    
    /// Determines the message menu alignment based on ChatType and message sender.
    private func menuAlignment(_ message: Message, chatType: ChatType) -> MessageMenuAlignment {
        switch chatType {
        case .conversation:
            return message.user.isCurrentUser ? .right : .left
        case .comments:
            return .left
        }
    }
    
    /// Our default reactionCallback flow if the user supports Reactions by implementing the didReactToMessage closure
    private func reactionClosure(_ message: Message) -> (ReactionType?) -> () {
        return { reactionType in
            Task {
                // Run the callback on the main thread
                await MainActor.run {
                    // Hide the menu
                    hideMessageMenu()
                    // Send the draft reaction
                    guard let reactionDelegate, let reactionType else { return }
                    reactionDelegate.didReact(to: message, reaction: DraftReaction(messageID: message.id, type: reactionType))
                }
            }
        }
    }
    
    /// Our default Menu Action closure
    func menuActionClosure(_ message: Message) -> (MenuAction) -> () {
        if let messageMenuAction {
            return { action in
                hideMessageMenu()
                messageMenuAction(action, viewModel.messageMenuAction(), message)
            }
        } else if MenuAction.self == DefaultMessageMenuAction.self {
            return { action in
                hideMessageMenu()
                viewModel.messageMenuActionInternal(message: message, action: action as! DefaultMessageMenuAction)
            }
        }
        return { _ in }
    }

    func showMessageMenu() {
        isShowingMenu = true
    }
    
    func hideMessageMenu() {
        viewModel.messageMenuRow = nil
        viewModel.messageFrame = .zero
        isShowingMenu = false
    }
    
    private func chatBackground() -> some View {
        Group {
            
            if let background = theme.images.background {
                
                switch (isLandscape(), colorScheme) {
                case (true, .dark):
                    background.landscapeBackgroundDark
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (true, .light):
                    background.landscapeBackgroundLight
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (false, .dark):
                    background.portraitBackgroundDark
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (false, .light):
                    background.portraitBackgroundLight
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                }
            } else {
                theme.colors.mainBG
            }
        }
    }
    
    private func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    private func isGiphyAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.giphy)
    }
    
    private static func createLocalization() -> ChatLocalization {
        return ChatLocalization(
            inputPlaceholder: String(localized: "Type a message..."),
            signatureText: String(localized: "Add signature..."),
            cancelButtonText: String(localized: "Cancel"),
            recentToggleText: String(localized: "Recents"),
            waitingForNetwork: String(localized: "Waiting for network"),
            recordingText: String(localized: "Recording..."),
            replyToText: String(localized: "Reply to")
        )
    }
}

public extension ChatView {
    
    func betweenListAndInputViewBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.betweenListAndInputViewBuilder = {
            AnyView(builder())
        }
        return view
    }
    
    func mainHeaderBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.mainHeaderBuilder = {
            AnyView(builder())
        }
        return view
    }
    
    func headerBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.headerBuilder = { date in
            AnyView(builder(date))
        }
        return view
    }
    
    func isListAboveInputView(_ isAbove: Bool) -> ChatView {
        var view = self
        view.isListAboveInputView = isAbove
        return view
    }
    
    func showDateHeaders(_ showDateHeaders: Bool) -> ChatView {
        var view = self
        view.showDateHeaders = showDateHeaders
        return view
    }
    
    func isScrollEnabled(_ isScrollEnabled: Bool) -> ChatView {
        var view = self
        view.isScrollEnabled = isScrollEnabled
        return view
    }
    
    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.showMessageMenuOnLongPress = show
        return view
    }
    
    /// Sets the keyboard dismiss mode for the chat list
    /// - Parameter mode: The keyboard dismiss mode (.interactive, .onDrag, or .none)
    /// - Default is .none
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> ChatView {
        var view = self
        view.keyboardDismissMode = mode
        return view
    }
    
    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.showNetworkConnectionProblem = show
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
    
    /// when user scrolls up to `pageSize`-th meassage, call the handler function, so user can load more messages
    /// NOTE: doesn't work well with `isScrollEnabled` false
    func enableLoadMore(pageSize: Int, _ handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view.paginationHandler = PaginationHandler(handleClosure: handler, pageSize: pageSize)
        return view
    }
    
    @available(*, deprecated)
    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        var view = self
        view.chatTitle = title
        return view.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }
    
    // makes sense only for built-in message view
    
    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }
    
    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.tapAvatarClosure = closure
        return view
    }
    
    func messageUseMarkdown(_ messageUseMarkdown: Bool) -> ChatView {
        return messageUseStyler(String.markdownStyler)
    }

    func messageUseStyler(_ styler: @escaping (String) -> AttributedString) -> ChatView {
        var view = self
        view.messageStyler = styler
        return view
    }
    
    func shouldShowLinkPreview(_ shouldShowLinkPreview: @escaping (URL) -> Bool) -> ChatView {
        var view = self
        view.shouldShowLinkPreview = shouldShowLinkPreview
        return view
    }

    func showMessageTimeView(_ isShow: Bool) -> ChatView {
        var view = self
        view.showMessageTimeView = isShow
        return view
    }

    func messageLinkPreviewLimit(_ limit: Int) -> ChatView {
        var view = self
        view.messageLinkPreviewLimit = limit
        return view
    }
    
    func linkPreviewsDisabled() -> ChatView {
        return messageLinkPreviewLimit(0)
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageFont = font
        return view
    }
    
    // makes sense only for built-in input view
    
    func setAvailableInputs(_ types: [AvailableInputType]) -> ChatView {
        var view = self
        view.availableInputs = types
        return view
    }
    
    func setRecorderSettings(_ settings: RecorderSettings) -> ChatView {
        var view = self
        view.recorderSettings = settings
        return view
    }
    
    /// Sets the general duration of various message menu animations
    ///
    /// This value is more akin to 'how snappy' the message menu feels
    /// - Note: Good values are between 0.15 - 0.5 (defaults to 0.3)
    /// - Important: This value is clamped between 0.1 and 1.0
    func messageMenuAnimationDuration(_ duration:Double) -> ChatView {
        var view = self
        view.messageMenuAnimationDuration = max(0.1, min(1.0, duration))
        return view
    }
    
    /// Sets a ReactionDelegate on the ChatView for handling and configuring message reactions
    func messageReactionDelegate(_ configuration: ReactionDelegate) -> ChatView {
        var view = self
        view.reactionDelegate = configuration
        return view
    }
    
    /// Constructs, and applies, a ReactionDelegate for you based on the provided closures
    func onMessageReaction(
        didReactTo: @escaping (Message, DraftReaction) -> Void,
        canReactTo: ((Message) -> Bool)? = nil,
        availableReactionsFor: ((Message) -> [ReactionType]?)? = nil,
        allowEmojiSearchFor: ((Message) -> Bool)? = nil,
        shouldShowOverviewFor: ((Message) -> Bool)? = nil
    ) -> ChatView {
        var view = self
        view.reactionDelegate = DefaultReactionConfiguration(
            didReact: didReactTo,
            canReact: canReactTo,
            reactions: availableReactionsFor,
            allowEmojiSearch: allowEmojiSearchFor,
            shouldShowOverview: shouldShowOverviewFor
        )
        return view
    }
}

//#Preview {
//    let romeo = User(id: "romeo", name: "Romeo Montague", avatarURL: nil, isCurrentUser: true)
//    let juliet = User(id: "juliet", name: "Juliet Capulet", avatarURL: nil, isCurrentUser: false)
//
//    let monday = try! Date.iso8601Date.parse("2025-05-12")
//    let tuesday = try! Date.iso8601Date.parse("2025-05-13")
//
//    ChatView(messages: [
//        Message(
//            id: "26tb", user: romeo, status: .read, createdAt: monday,
//            text: "And I’ll still stay, to have thee still forget"),
//        Message(
//            id: "zee6", user: romeo, status: .read, createdAt: monday,
//            text: "Forgetting any other home but this"),
//
//        Message(
//            id: "oWUN", user: juliet, status: .read, createdAt: monday,
//            text: "’Tis almost morning. I would have thee gone"),
//        Message(
//            id: "P261", user: juliet, status: .read, createdAt: monday,
//            text: "And yet no farther than a wanton’s bird"),
//        Message(
//            id: "46hu", user: juliet, status: .read, createdAt: monday,
//            text: "That lets it hop a little from his hand"),
//        Message(
//            id: "Gjbm", user: juliet, status: .read, createdAt: monday,
//            text: "Like a poor prisoner in his twisted gyves"),
//        Message(
//            id: "IhRQ", user: juliet, status: .read, createdAt: monday,
//            text: "And with a silken thread plucks it back again"),
//        Message(
//            id: "kwWd", user: juliet, status: .read, createdAt: monday,
//            text: "So loving-jealous of his liberty"),
//
//        Message(
//            id: "9481", user: romeo, status: .read, createdAt: tuesday,
//            text: "I would I were thy bird"),
//
//        Message(
//            id: "dzmY", user: juliet, status: .sent, createdAt: tuesday, text: "Sweet, so would I"),
//        Message(
//            id: "r5HH", user: juliet, status: .sent, createdAt: tuesday,
//            text: "Yet I should kill thee with much cherishing"),
//        Message(
//            id: "quy1", user: juliet, status: .sent, createdAt: tuesday,
//            text: "Good night, good night. Parting is such sweet sorrow"),
//        Message(
//            id: "Mwh6", user: juliet, status: .sent, createdAt: tuesday,
//            text: "That I shall say 'Good night' till it be morrow"),
//    ]) { draft in }
//}

//public extension ChatView where MessageContent == EmptyView {
//
//    init(messages: Binding<[Message]>,
//         chatType: ChatType = .conversation,
//         replyMode: ReplyMode = .quote,
//         didSendMessage: @escaping (DraftMessage) -> Void,
//         reactionDelegate: ReactionDelegate? = nil,
//         inputViewBuilder: @escaping InputViewBuilderClosure,
//         messageMenuAction: MessageMenuActionClosure?) {
//        print(">>>> ChatView inited")
//        self.type = chatType
//        self.didSendMessage = didSendMessage
//        self.reactionDelegate = reactionDelegate
//        self._messages = messages
//        self.sections = ChatView.mapMessages(messages.wrappedValue, chatType: chatType, replyMode: replyMode)
//        self.ids = messages.wrappedValue.map { $0.id }
//        self.inputViewBuilder = inputViewBuilder
//        self.messageMenuAction = messageMenuAction
//        self.chatType = chatType
//        self.replyMode = replyMode
//    }
//}

//public extension ChatView where InputViewContent == EmptyView {
//
//    init(messages: Binding<[Message]>,
//         chatType: ChatType = .conversation,
//         replyMode: ReplyMode = .quote,
//         didSendMessage: @escaping (DraftMessage) -> Void,
//         reactionDelegate: ReactionDelegate? = nil,
//         messageBuilder: @escaping MessageBuilderClosure,
//         messageMenuAction: MessageMenuActionClosure?) {
//        print(">>>> ChatView inited")
//        self.type = chatType
//        self.didSendMessage = didSendMessage
//        self._messages = messages
//        self.reactionDelegate = reactionDelegate
//        self.sections = ChatView.mapMessages(messages.wrappedValue, chatType: chatType, replyMode: replyMode)
//        self.ids = messages.wrappedValue.map { $0.id }
//        self.messageBuilder = messageBuilder
//        self.messageMenuAction = messageMenuAction
//        self.chatType = chatType
//        self.replyMode = replyMode
//    }
//}

//public extension ChatView where MenuAction == DefaultMessageMenuAction {
//
//    init(messages: Binding<[Message]>,
//         chatType: ChatType = .conversation,
//         replyMode: ReplyMode = .quote,
//         didSendMessage: @escaping (DraftMessage) -> Void,
//         reactionDelegate: ReactionDelegate? = nil,
//         messageBuilder: @escaping MessageBuilderClosure,
//         inputViewBuilder: @escaping InputViewBuilderClosure) {
//        print(">>>> ChatView inited")
//        self.type = chatType
//        self.didSendMessage = didSendMessage
//        self.reactionDelegate = reactionDelegate
//        self._messages = messages
//        self.sections = ChatView.mapMessages(messages.wrappedValue, chatType: chatType, replyMode: replyMode)
//        self.ids = messages.wrappedValue.map { $0.id }
//        self.messageBuilder = messageBuilder
//        self.inputViewBuilder = inputViewBuilder
//        self.chatType = chatType
//        self.replyMode = replyMode
//    }
//}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {

    init(messages: Binding<[Message]>,
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageMenuAction: MessageMenuActionClosure?) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages.wrappedValue, chatType: chatType, replyMode: replyMode)
        self.ids = messages.wrappedValue.map { $0.id }
        self.messageMenuAction = messageMenuAction
    }
}
