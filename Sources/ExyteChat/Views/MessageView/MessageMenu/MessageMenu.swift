//
//  MessageMenu.swift
//
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI

enum MessageMenuAlignment {
    case left
    case right
}

struct MessageMenu<MainButton: View, ActionEnum: MessageMenuAction>: View {
    
    struct ReactionConfig {
        /// The delegate used to configure our Reaction views on a per message basis
        var delegate: ReactionDelegate?
        /// Our internal didReact handler that allows for proper view dismissal
        var didReact: (ReactionType?) -> ()
    }

    @Environment(\.chatTheme) private var theme
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var keyboardState = KeyboardState()
    @StateObject var viewModel: ChatViewModel
    
    @Binding var isShowingMenu: Bool
    
    /// Overall ChatView Frame
    let chatViewFrame: CGRect = UIScreen.main.bounds
    
    /// The max height for the menu
    /// - Note: menus that exceed this value will be placed in a ScrollView
    let maxMenuHeight: CGFloat = 200
    
    /// The vertical spacing between the main three components in out VStack (ReactionSelection, Message and Menu)
    let verticalSpacing:CGFloat = 0
    
    /// The message whose menu we're presenting
    var message: Message
    /// The original message frame (the row / cell)
    var cellFrame: CGRect
    /// Leading / Trailing message alignment
    var alignment: MessageMenuAlignment
    /// The position in user group of the message
    var positionInUserGroup: PositionInUserGroup
    /// Leading padding (includes space for avatar)
    var leadingPadding: CGFloat
    /// Trailing padding
    var trailingPadding: CGFloat
    /// The font we should use to render our message menu button
    var font: UIFont? = nil
    /// The duration most of our animations take
    /// - Note: This value is more akin to 'how snappy' the menu feels. Good values are between 0.15 - 0.5
    var animationDuration: Double = 0.3
    /// The animation to use for displaying / dismissing this view
    var defaultTransition: AnyTransition = .scaleAndFade
    /// The menu button actions to be rendered
    var onAction: (ActionEnum) -> ()
    /// The current reaction configuration (delegate and callback)
    var reactionHandler: ReactionConfig
    /// The main message, rendered as a button
    var mainButton: () -> MainButton

    /// The vertical offset necessary to ensure the message, and it's surrounding components,
    /// are visible on screen, and within the vertical safeAreaInsets.
    @State private var verticalOffset: CGFloat = 0
    /// The horizontal offset necessary to ensure the message, and it's surrounding components,
    /// are visible on screen, and within the horizontal safeAreaInsets.
    @State private var horizontalOffset: CGFloat = 0
    /// Used to store the previous `verticalOffset` when launching the emoji keyboard
    @State private var lastVerticalOffset: CGFloat = 0
    
    /// The current state that this view is in
    @State private var viewState: ViewState = .initial
    
    /// The style the message menu should be presented in
    /// Either a VStack or a ScrollView
    @State private var messageMenuStyle: MenuStyle = .vStack
    
    /// The style the menu should be presented in
    /// Either a VStack or a ScrollView
    @State private var menuStyle: MenuStyle = .vStack
    
    /// The Rendered MessageFrame Size
    /// - Note: These get populated during the `.prepare` viewState
    @State private var messageFrame: CGRect = .zero
    @State private var messageMenuFrame: CGRect = .zero
    @State private var reactionSelectionHeight: CGFloat = .zero
    @State private var reactionOverviewHeight: CGFloat = .zero
    @State private var reactionOverviewWidth: CGFloat = .zero
    @State private var menuHeight: CGFloat = .zero
    
    /// Controls whether or not the reaction selection view is rendered
    @State private var reactionSelectionIsVisible: Bool = true
    /// Controls whether or not the reaction overview is rendered
    @State private var reactionOverviewIsVisible: Bool = false
    /// Controls whether or not the menu view is rendered
    @State private var menuIsVisible: Bool = true
    
    /// Dynamic padding amounts
    @State private var reactionSelectionBottomPadding: CGFloat = 0
    @State private var messageTopPadding: CGFloat = 0
    /// Dynamic opacity vars
    @State private var messageMenuOpacity: CGFloat = 0.0
    @State private var backgroundOpacity: CGFloat = 0.0
    
    /// This flag is used to adjust the dismiss animation
    @State private var didReact: Bool = false
    /// We use this `onReaction` handler in order to set our `didReact` flag and kick off the dismissal sequence
    private func handleOnReaction(_ rt: ReactionType?) {
        guard let rt else { transitionViewState(to: .ready); return }
        didReact = true
        dismissSelf(rt)
    }
    
    /// The max height for the entire message menu and surrounding views
    var maxEntireHeight: CGFloat {
        self.chatViewFrame.height
    }
    
    /// Unwraps and returns our optional `UIFont` as a `Font` or `nil`
    var getFont: Font? {
        if let font {
            return Font(font)
        } else {
            return nil
        }
    }
    
    var shouldShowReactionSelectionView: Bool {
        guard let delegate = reactionHandler.delegate else { return false }
        return delegate.canReact(to: message)
    }
    
    var shouldShowReactionOverviewView: Bool {
        guard let delegate = reactionHandler.delegate else { return false }
        return delegate.shouldShowOverview(for: message)
    }
    
    var shouldAllowEmojiSearch: Bool {
        guard let delegate = reactionHandler.delegate else { return false }
        return delegate.allowEmojiSearch(for: message)
    }
    
    var reactions: [ReactionType]? {
        guard let delegate = reactionHandler.delegate else { return nil }
        return delegate.reactions(for: message)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            
            // Reaction Overview Rectangle
            if reactionOverviewIsVisible, case .vStack = messageMenuStyle {
                ReactionOverview(viewModel: viewModel, message: message, width: reactionOverviewWidth, backgroundColor: theme.colors.messageFriendBG, inScrollView: false)
                    .frame(width: reactionOverviewWidth)
                    .maxHeightGetter($reactionOverviewHeight)
                    .offset(y: UIApplication.safeArea.top)
                    .transition(defaultTransition)
                    .opacity(messageMenuOpacity)
            }
            
            // Some views to help debug layout and animations
            //debugViews()
            
            // The message and menu view
            messageMenuView()
                .frameGetter($messageMenuFrame)
                .position(x: chatViewFrame.width / 2 + horizontalOffset, y: verticalOffset)
                .opacity(messageMenuOpacity)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(
            ZStack {
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial)
                Rectangle()
                    .fill(.primary.opacity(0.1))
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(backgroundOpacity)
            .onTapGesture {
                if viewState == .keyboard {
                    keyboardState.resignFirstResponder()
                    transitionViewState(to: .ready)
                } else {
                    dismissSelf()
                }
            }
        )
        .onAppear {
            transitionViewState(to: .prepare)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(animationDuration * 333))) {
                transitionViewState(to: .original)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(animationDuration * 666))) {
                transitionViewState(to: .ready)
            }
        }
        .onChange(of: keyboardState.keyboardFrame) { _ in
            if viewState == .ready, keyboardState.isShown {
                transitionViewState(to: .keyboard)
            }
        }
    }
    
    @MainActor
    private func transitionViewState(to vs: ViewState) {
        guard viewState != vs, viewState != .dismiss, vs != .initial else { return }
        let oldState = viewState
        viewState = vs
        switch viewState {
        case .initial:
            fatalError("Shouldn't be called")
            
        case .prepare:
            /// Ensure we set this to true
            isShowingMenu = true
            
            /// Set our view state variables
            reactionSelectionBottomPadding = positionInUserGroup == .middle || positionInUserGroup == .last ? 4 : 0
            reactionOverviewWidth = chatViewFrame.width - UIApplication.safeArea.leading - UIApplication.safeArea.trailing
            reactionOverviewIsVisible = shouldShowReactionOverviewView
            reactionSelectionIsVisible = shouldShowReactionSelectionView
            menuIsVisible = true
            verticalOffset = UIScreen.main.bounds.height * 2
            
            /// Kick off the background animation
            withAnimation(.easeInOut(duration: animationDuration)) {
                backgroundOpacity = 1.0
            }
            
        case .original:
            /// Our views were rendered transparently in the `.prepare` state allowing us to
            /// capture their preferred sizes (based on the devices dynamic text), so now we can configure our view

            /// If we have a detailed message frame stored in the viewModel use it, otherwise fall back to the cell's frame
            /// - Note: this optional message frame allows us to place the reaction at the correct spot on the message (top left / right corner)
            if viewModel.messageFrame == .zero {
                print("WARNING::ViewModel.MessageFrame not set")
                viewModel.messageFrame = cellFrame
            }
            
            /// If we're in landscape mode, adjust the `horizontalOffset` appropriately
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                switch alignment {
                case .left:
                    horizontalOffset = UIApplication.safeArea.leading
                case .right:
                    horizontalOffset = -UIApplication.safeArea.trailing
                }
            }
            messageFrame = .init(
                x: viewModel.messageFrame.origin.x + horizontalOffset,
                y: cellFrame.maxY - (viewModel.messageFrame.height),
                width: viewModel.messageFrame.width,
                height: viewModel.messageFrame.height
            )
            
            messageTopPadding = 4
            
            /// Calculate our vertical safe area insets
            let safeArea = UIApplication.safeArea.top + UIApplication.safeArea.bottom
            /// Calculate our ReactionOverview height
            let rOHeight:CGFloat = reactionOverviewIsVisible ? reactionOverviewHeight : 0
            /// We calculate the total height here, instead of using messageMenuFrame.height
            /// messageMenuHeight renders the menu buttons in a VStack by default, and we need to account for the clamping of the menu height
            let totalMenuHeight = calculateMessageMenuHeight(including: [.message, .reactionSelection]) + min(menuHeight, maxMenuHeight)
            /// Compare our total menu height with our free screen space to determine if we need to place it in a ScrollView or not
            if ( totalMenuHeight + rOHeight ) > maxEntireHeight - safeArea {
                /// We need to place our entire view in a ScrollView
                messageMenuStyle = .scrollView(height: maxEntireHeight - safeArea)
            } else if menuHeight > maxMenuHeight {
                /// We need to place our menu buttons in a ScrollView
                menuStyle = .scrollView(height: maxMenuHeight)
            }
            /// Update our view state variables
            /// Hide all of our views in preperation for our transition to `.ready`
            reactionSelectionIsVisible = false
            reactionOverviewIsVisible = false
            menuIsVisible = false
            /// Calculate our vertical offset so our message lines up with the message from our TableView
            verticalOffset = calcVertOffset(previousState: oldState)
            /// Animate our rendered message into view
            withAnimation(.easeInOut(duration: animationDuration * 1.33)) {
                messageMenuOpacity = 1.0
            }
            
        case .ready:
            withAnimation(.bouncy(duration: animationDuration)) {
                reactionSelectionIsVisible = shouldShowReactionSelectionView
                reactionOverviewIsVisible = shouldShowReactionOverviewView
                menuIsVisible = true
                verticalOffset = calcVertOffset(previousState: oldState)
            }
            
        case .keyboard:
            withAnimation(.bouncy(duration: animationDuration)) {
                reactionSelectionIsVisible = true
                reactionOverviewIsVisible = false
                menuIsVisible = false
                verticalOffset = calcVertOffset(previousState: oldState)
            }
            
        case .dismiss:
            withAnimation(.snappy(duration: animationDuration * 0.66)) {
                reactionSelectionIsVisible = didReact ? true : false
                reactionOverviewIsVisible = false
                menuIsVisible = false
                verticalOffset = calcVertOffset(previousState: oldState)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(animationDuration * 333))) {
                withAnimation(.easeOut) {
                    messageMenuOpacity = 0
                    backgroundOpacity = 0
                }
            }
        }
    }
    
    private func calcVertOffset(previousState: ViewState) -> CGFloat {
        switch viewState {
        case .initial, .prepare:
            return .greatestFiniteMagnitude
        case .original:
            return messageFrame.midY - (messageTopPadding / 2)
        case .ready:
            if case .keyboard = previousState {
                if case .scrollView = messageMenuStyle {
                    /// Ensure we still need our scroll view
                    let rOHeight: CGFloat = reactionOverviewIsVisible ? reactionOverviewHeight : 0
                    let contentHeight = calculateMessageMenuHeight(including: [.message, .reactionSelection, .menu]) + rOHeight
                    let safeArea = UIApplication.safeArea.top + UIApplication.safeArea.bottom
                    if contentHeight > maxEntireHeight - safeArea {
                        messageMenuStyle = .scrollView(height: maxEntireHeight - safeArea)
                    } else {
                        messageMenuStyle = .vStack
                    }
                }
                return lastVerticalOffset
            }
            /// If the messageMenuStyle is a scrollView then we place it in the middle of the screen
            if case .scrollView(let height) = messageMenuStyle { return (height / 2) + UIApplication.safeArea.top }

            /// Otherwise, calculate our offsets and move to our target
            let rHeight: CGFloat = reactionSelectionIsVisible ? calculateMessageMenuHeight(including: [.reactionSelection]) : 0
            let mHeight: CGFloat = menuIsVisible ? calculateMessageMenuHeight(including: [.menu]) : 0
            let rOHeight: CGFloat = reactionOverviewIsVisible ? reactionOverviewHeight : 0

            var ty: CGFloat = messageFrame.midY - (messageTopPadding / 2)

            if (messageFrame.minY - rHeight) < UIApplication.safeArea.top + rOHeight {
                let off = (UIApplication.safeArea.top + rOHeight) - (messageFrame.minY - rHeight)
                /// We need to move the message down to make room for the views above it
                ty += off
            } else if messageFrame.maxY + mHeight > chatViewFrame.height - UIApplication.safeArea.bottom {
                let off = messageFrame.maxY + mHeight + UIApplication.safeArea.bottom - chatViewFrame.height
                /// We need to move the message up to make room for the menu buttons below it
                ty -= off
            }
            
            return ty + (mHeight / 2) - (rHeight / 2)
            
        case .keyboard:
            /// Store our vertical offset
            lastVerticalOffset = verticalOffset

            /// If the messageMenuStyle is a scrollView then we place it in the middle of the screen
            if case .scrollView(let height) = messageMenuStyle {
                /// Update our max height
                messageMenuStyle = .scrollView(height: height - keyboardState.keyboardFrame.height + UIApplication.safeArea.bottom)
                /// And our vertical offset
                return verticalOffset - (keyboardState.keyboardFrame.height / 2) + (UIApplication.safeArea.bottom / 2)
            } else {
                /// Check to make sure that we don't need a scroll view now that we have less realestate
                let contentHeight = calculateMessageMenuHeight(including: [.message, .reactionSelection])
                if contentHeight + UIApplication.safeArea.top > keyboardState.keyboardFrame.minY {
                    /// Our message is too large to fit in our available screen space
                    /// We *should* place the content in a ScrollView
                    /// But we don't due to needing to preserve the ReactionSelection's view state
                    /// Therefore we settle with clipping the bottom of the content behind the keyboard
                    /// Pin the view to the top of the screen
                    return UIApplication.safeArea.top + (contentHeight / 2)
                }
            }
            
            /// At this point our messageMenuFrame height includes the menu view so we need to subtract that
            let mHeight: CGFloat = calculateMessageMenuHeight(including: [.menu])

            /// Grab our current verticalOffset
            var ty: CGFloat = verticalOffset
            /// Keep the message stationary while we hide / remove the menu
            ty -= mHeight / 2
            /// Provide a bit of padding to lift the view off of the keyboard
            let bottomPadding = UIApplication.safeArea.bottom / 2
            if messageMenuFrame.maxY - mHeight + bottomPadding > keyboardState.keyboardFrame.minY {
                let off = messageMenuFrame.maxY - mHeight + bottomPadding - keyboardState.keyboardFrame.minY
                /// We need to move the message up so it doesn't get hidden by the keyboard
                ty -= off
            }
            return ty
            
        case .dismiss:
            if didReact {
                return messageFrame.midY - ((calculateMessageMenuHeight(including: [.reactionSelection])) / 2)
            } else {
                return messageFrame.midY - (messageTopPadding / 2)
            }
        }
    }
    
    enum MMViews {
        case message
        case menu
        case reactionSelection
    }
    
    /// Attempts to provide a single call site for gathering the height of our various views
    private func calculateMessageMenuHeight(including views: [MMViews]) -> CGFloat {
        var height: CGFloat = 0
        for view in Set(views) {
            switch view {
            case .message:
                height += messageFrame.height + messageTopPadding
            case .menu:
                height += menuStyle.height(menuHeight) + verticalSpacing
                if case .scrollView = menuStyle { height += 8 }
            case .reactionSelection:
                height += reactionSelectionHeight + verticalSpacing + reactionSelectionBottomPadding
            }
        }
        return height
    }
    
    @ViewBuilder
    func messageMenuView() -> some View {
        VStack(spacing: verticalSpacing) {
            if reactionOverviewIsVisible, case .scrollView = messageMenuStyle {
                ReactionOverview(viewModel: viewModel, message: message, width: reactionOverviewWidth, backgroundColor: theme.colors.messageFriendBG, inScrollView: true)
                    .frame(width: reactionOverviewWidth)
                    .maxHeightGetter($reactionOverviewHeight)
                    //.offset(y: safeAreaInsets.top)
                    .transition(defaultTransition)
                    .opacity(messageMenuOpacity)
            }
            
            if reactionSelectionIsVisible {
                ReactionSelectionView(
                    viewModel: viewModel,
                    backgroundColor: theme.colors.messageFriendBG,
                    selectedColor: theme.colors.messageMyBG,
                    animation: .bouncy(duration: animationDuration),
                    animationDuration: animationDuration,
                    currentReactions: message.reactions.filter({ $0.user.isCurrentUser }),
                    customReactions: reactions,
                    allowEmojiSearch: shouldAllowEmojiSearch,
                    alignment: alignment,
                    leadingPadding: leadingPadding,
                    trailingPadding: trailingPadding,
                    reactionClosure: handleOnReaction
                )
                .maxHeightGetter($reactionSelectionHeight)
                .padding(.bottom, reactionSelectionBottomPadding)
                .transition(defaultTransition)
                .zIndex(2)
            }
            
            mainButton()
                .frame(maxWidth: chatViewFrame.width - UIApplication.safeArea.leading - UIApplication.safeArea.trailing)
                .offset(x: (alignment == .right) ? UIApplication.safeArea.trailing : -UIApplication.safeArea.leading)
                .allowsHitTesting(false)
            
            if menuIsVisible {
                menuView()
                    .transition(defaultTransition)
            }
        }
        .overflowContainer(messageMenuStyle, viewState: viewState, onTap: {
            if viewState == .keyboard {
                keyboardState.resignFirstResponder()
                transitionViewState(to: .ready)
            } else {
                dismissSelf()
            }
        })
    }
    
    private struct MenuButton: Identifiable {
        let id: Int
        let action: ActionEnum

        init(id: Int, action: ActionEnum) {
            self.id = id
            self.action = action
        }
    }
    
    @ViewBuilder
    func menuView() -> some View {
        let buttons = ActionEnum.menuItems(for: message).enumerated().map { MenuButton(id: $0, action: $1) }
        HStack {
            if alignment == .right { Spacer() }
            
            VStack {
                ForEach(buttons) { button in
                    menuButton(title: button.action.title(), icon: button.action.icon(), action: button.action)
                }
            }
            .menuContainer(menuStyle)
            
            if alignment == .left { Spacer() }
        }
        .padding(alignment == .right ? .trailing : .leading, alignment == .right ? trailingPadding : leadingPadding)
        .padding(.top, 8)
        .maxHeightGetter($menuHeight)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func menuButton(title: String, icon: Image, action: ActionEnum) -> some View {
        HStack(spacing: 0) {
            ZStack {
                theme.colors.messageFriendBG
                    .cornerRadius(12)
                HStack {
                    Text(title)
                        .foregroundColor(theme.colors.menuText)
                    Spacer()
                    icon
                        .renderingMode(.template)
                        .foregroundStyle(theme.colors.menuText)
                }
                .font(getFont)
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
            }
            .frame(width: 208)
            .fixedSize()
            .onTapGesture {
                onAction(action)
                dismissSelf()
            }

            if alignment == .right {
                /// This aligns the menu buttons with the trailing edge of the message instead of the status indicator
                Color.clear.viewWidth(12)
            }
        }
    }
    
    private func dismissSelf(_ rt: ReactionType? = nil) {
        if keyboardState.isShown { keyboardState.resignFirstResponder() }
        transitionViewState(to: .dismiss)
        let delay = didReact ? Int(animationDuration * 1333) : Int(animationDuration * 1000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            isShowingMenu = false
            reactionHandler.didReact(rt)
            dismiss()
        }
    }
}

enum ViewState {
    case initial
    case prepare
    case original
    case ready
    case keyboard
    case dismiss
}

enum MenuStyle {
    case vStack
    case scrollView(height: CGFloat)
    
    func height(_ maxMenuHeight: CGFloat) -> CGFloat {
        switch self {
        case .vStack:
            return maxMenuHeight
        case .scrollView(let height):
            return height
        }
    }
}

// - MARK: Debug Views
extension MessageMenu {
    @ViewBuilder
    func debugViews() -> some View {
        // Original Message Frame
        Rectangle()
            .fill(.clear)
            .border(.blue)
            .frame(width: cellFrame.width, height: cellFrame.height)
            .position(x: cellFrame.midX, y: cellFrame.midY)
        // Current Message Frame
        Rectangle()
            .fill(.clear)
            .border(.purple)
            .frame(width: messageFrame.width, height: messageFrame.height)
            .position(x: messageFrame.midX, y: messageFrame.midY)
        // Target
        Rectangle()
            .fill(.orange)
            .frame(width: messageMenuFrame.width, height: 2)
            .position(x: messageMenuFrame.midX, y: messageMenuFrame.midY)
        // Top Safe Area
        Rectangle()
            .fill(.red)
            .opacity(0.3)
            .frame(width: chatViewFrame.width, height: UIApplication.safeArea.top)
            .position(x: chatViewFrame.midX, y: UIApplication.safeArea.top / 2)
        // Bottom Safe Area
        Rectangle()
            .fill(.red)
            .opacity(0.3)
            .frame(width: chatViewFrame.width, height: UIApplication.safeArea.bottom)
            .position(x: chatViewFrame.midX, y: chatViewFrame.height - (UIApplication.safeArea.bottom / 2))
    }
}

struct MenuContainerModifier: ViewModifier {
    @State var style: MenuStyle
    var background: Color
    
    func body(content: Content) -> some View {
        switch style {
        case .vStack:
            content
        case .scrollView(let height):
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)
            .frame(height: height)
            .background(background)
        }
    }
}

struct ScrollContainerModifier: ViewModifier {
    var style: MenuStyle
    var viewState: ViewState
    var background: Color
    var onTap: () -> Void
    
    func body(content: Content) -> some View {
        if (viewState != .initial || viewState != .prepare), case .scrollView(let height) = style {
            ScrollView {
                content
            }
            .clipped()
            .frame(maxHeight: height)
            .onTapGesture(perform: onTap)
        } else {
            content
        }
    }
}

extension View {
    func overflowContainer(_ style: MenuStyle, viewState: ViewState, background: Color = .clear, onTap: @escaping () -> Void) -> some View {
        modifier(ScrollContainerModifier(style: style, viewState: viewState, background: background, onTap: onTap))
    }
    
    func menuContainer(_ style: MenuStyle, background: Color = .clear) -> some View {
        modifier(MenuContainerModifier(style: style, background: background))
    }
}
