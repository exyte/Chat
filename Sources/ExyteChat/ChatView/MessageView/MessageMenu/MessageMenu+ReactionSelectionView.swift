//
//  ReactionSelectionView.swift
//  Chat
//

import SwiftUI

struct ReactionSelectionView: View {
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    static let MaxSelectionRowWidth:CGFloat = 400
    
    @StateObject private var keyboardState = KeyboardState()
    
    @StateObject var viewModel: ChatViewModel
    
    @State private var selectedEmoji: String = ""
    @FocusState private var emojiEntryIsFocused: Bool
    
    @State private var emojis:[String] = []
   
    @State private var placeholder: String = ""
    @State private var maxWidth: CGFloat = ReactionSelectionView.MaxSelectionRowWidth
    @State private var maxSelectionRowWidth: CGFloat = ReactionSelectionView.MaxSelectionRowWidth
    @State private var maxHeight: CGFloat? = nil
    @State private var opacity: CGFloat = 1.0
    @State private var xOffset: CGFloat = 0.0
    @State private var yOffset: CGFloat = 0.0
    @State private var viewState: ViewState = .initial
    
    @State private var bubbleDiameter: CGFloat = .zero
    
    var backgroundColor: Color
    var selectedColor: Color
    var animation: Animation
    var animationDuration: Double
    var currentReactions: [Reaction]
    var customReactions: [ReactionType]?
    var allowEmojiSearch: Bool
    var alignment: MessageMenuAlignment
    var leadingPadding: CGFloat
    var trailingPadding: CGFloat
    var reactionClosure: ((ReactionType?) -> Void)
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 10
    private let bubbleDiameterMultiplier: CGFloat = 1.5
    
    var body: some View {
        let currentEmojiReactions = currentReactions.compactMap(\.emoji)
        HStack(spacing: 0) {
            // Apply the leading padding
            leadingPaddingView()

            // The main reaction selection view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: horizontalPadding) {
                    // Add the latest / most relevant emojis
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            transitionToViewState(.picked(emoji))
                        }) {
                            emojiView(emoji: emoji, isSelected: currentEmojiReactions.contains( emoji ))
                        }
                    }
                    
                    if allowEmojiSearch, viewState.needsSearchButton {
                        // Finish the list with a `button` to open the keyboard in it's emoji state
                        additionalEmojiPickerView()
                            .onChange(of: selectedEmoji) { _ in
                                transitionToViewState(.picked(selectedEmoji))
                            }
                            .onChange(of: emojiEntryIsFocused) { _ in
                                if emojiEntryIsFocused {
                                    transitionToViewState(.search)
                                }
                            }
                    }
                }
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, (emojiEntryIsFocused || viewState.isPicked) ? bubbleDiameter / 6 : horizontalPadding)
                
            }
            .padding(.horizontal, 2)
            .modifier(InteriorRadialShadow(color: viewState.needsInteriorShadow ? backgroundColor : .clear))
            .frame(minWidth: maxHeight, maxWidth: maxWidth, minHeight: maxHeight, maxHeight: maxHeight)
            .background(
                Capsule(style: .continuous)
                    .foregroundStyle(backgroundColor)
            )
            .clipShape(
                Capsule(style: .continuous)
            )
            .opacity(opacity)
            
            if emojiEntryIsFocused {
                // Provide a close button that cancels the emoji search
                // (dismisses the keyboard) and returns to the .row ViewState
                closeButton(color: backgroundColor)
                    .padding(.trailing, alignment == .left ? -24 : 0)
                    .transition(.scaleAndFade)
            }

            // Apply the trailing padding
            trailingPaddingView()
        }
        .offset(x: xOffset, y: yOffset)
        .onAppear { transitionToViewState(.row) }
        .onChange(of: keyboardState.isShown) { _ in
            if !keyboardState.isShown && viewState == .search {
                // Someone closed the keyboard while we were searching, return to `.row`
                transitionToViewState(.row)
            }
        }
    }
    
    @ViewBuilder
    func emojiView(emoji:String, isSelected:Bool) -> some View {
        if isSelected {
            Text(emoji)
                .font(.title3)
                .background(
                    Circle()
                        .fill(selectedColor)
                        .shadow(radius: 1)
                        .padding(-verticalPadding + 4)
                )
        } else {
            Text(emoji)
                .font(.title3)
        }
    }
    
    @ViewBuilder
    func additionalEmojiPickerView() -> some View {
        // Finish the list with a `button` to open the keyboard in it's emoji state
        EmojiTextField(placeholder: placeholder, text: $selectedEmoji)
            .tint(.clear)
            .font(.title3)
            .focused($emojiEntryIsFocused)
            .textSelection(.disabled)
            .background(
                ZStack {
                    Image(systemName: "face.smiling")
                        .imageScale(.large)
                        .foregroundStyle(selectedEmoji.isEmpty ? Color.secondary.opacity(0.35) : Color.clear)
                }
            )
            .frame(width: bubbleDiameter, height: bubbleDiameter)
    }
    
    @ViewBuilder
    func closeButton(color: Color) -> some View {
        Text("🅧")
            .font(.title)
            .foregroundStyle(.secondary)
            .background(
                ZStack {
                    Circle()
                        .stroke(style: .init(lineWidth: 1))
                        .fill(color)
                }
            )
            .onTapGesture {
                // We call the reaction closure here so our message menu can react accordingly
                reactionClosure(nil)
                // Transistion back to .row state
                transitionToViewState(.row)
            }
            .offset(x: -(bubbleDiameter / 3), y: -(bubbleDiameter / 1.5))
    }
    
    @ViewBuilder
    func leadingPaddingView() -> some View {
        if alignment == .left {
            Color.clear.viewWidth(max(1, leadingPadding - 8))
            Spacer()
        } else {
            let additionalPadding = max(0, UIScreen.main.bounds.width - maxSelectionRowWidth - trailingPadding)
            Color.clear.viewWidth(additionalPadding + trailingPadding * 3)
        }
    }
    
    @ViewBuilder
    func trailingPaddingView() -> some View {
        if alignment == .right {
            Spacer()
            Color.clear.viewWidth(trailingPadding)
        } else {
            let additionalPadding = max(0, UIScreen.main.bounds.width - maxSelectionRowWidth - leadingPadding)
            Color.clear.viewWidth(additionalPadding + trailingPadding * 3)
        }
    }
    
    private func calcMaxSelectionRowWidth() -> CGFloat {
        var emojiCount = emojis.count + 1
        if allowEmojiSearch { emojiCount += 1 }
        let maxWidth = min(
            CGFloat(emojiCount) * (bubbleDiameter + horizontalPadding) + horizontalPadding * 3,
            ReactionSelectionView.MaxSelectionRowWidth
        )
        return maxWidth
    }
    
    private func transitionToViewState(_ state:ViewState) {
        guard state != viewState else { return }
        let previousState = viewState
        viewState = state
        switch viewState {
        case .initial:
            self.transitionToViewState(.row)
            return
        case .row:
            bubbleDiameter = dynamicTypeSize.bubbleDiameter()
            emojiEntryIsFocused = false
            withAnimation(animation) {
                emojis = getEmojis()
                maxSelectionRowWidth = calcMaxSelectionRowWidth()
                maxWidth = maxSelectionRowWidth
                maxHeight = nil
                xOffset = CGFloat.leastNonzeroMagnitude
                yOffset = CGFloat.leastNonzeroMagnitude
            }
        case .search:
            withAnimation(animation) {
                emojis = []
                maxWidth = bubbleDiameter * bubbleDiameterMultiplier
                maxHeight = bubbleDiameter * bubbleDiameterMultiplier
                xOffset = getXOffset()
                yOffset = getYOffset()
            }
        case .picked(let emoji):
            withAnimation(animation) {
                emojis = [emoji]
                maxWidth = bubbleDiameter * bubbleDiameterMultiplier
                maxHeight = bubbleDiameter * bubbleDiameterMultiplier
                xOffset = getXOffset()
                yOffset = getYOffset()
            }
            
            switch previousState {
            case .row:
                Task {
                    try await Task.sleep(for: .milliseconds(animationDuration * 1333))
                    reactionClosure(.emoji(emoji))
                }
            case .search:
                emojiEntryIsFocused = false
                Task {
                    try await Task.sleep(for: .milliseconds(animationDuration * 666))
                    reactionClosure(.emoji(selectedEmoji))
                }
            case .initial, .picked:
                break
            }
        }
    }
    
    private func getEmojis() -> [String] {
        if let customReactions, !customReactions.isEmpty { return customReactions.map { $0.toString } }
        return defaultEmojis()
    }
    
    /// Constructs the default reaction list, containing any reactions the current user has already applied to this message
    /// - Returns: A list of emojis that the ReactionSelectionView should display
    /// - Note: We include the current senders past reactions so it's easier for the sender to remove / undo a reaction if the developer supports this.
    private func defaultEmojis() -> [String] {
        var standard = ["👍", "👎"]
        let current = currentReactions.compactMap(\.emoji).filter {
            !standard.contains($0)
        }
        standard.insert(contentsOf: current, at: 2)
        var extra = [ "❤️", "🤣", "‼️", "❓", "🥳", "💪", "🔥", "💔", "😭"]
        while !extra.isEmpty, standard.count < max(10, current.count + 2) {
            if let new = extra.firstIndex(where: { !standard.contains($0) }) {
                standard.append( extra.remove(at: new) )
            } else {
                break
            }
        }
        return Array(standard)
    }
    
    /// Calculates the X axis offset of the ReactionSelectionView for the current ViewState
    /// - Returns: The X axis offset for the ReactionSelectionView
    /// - Note: If the messageFrame's width is equal to, or larger than, the Screens width then we skip the offset animation
    /// - Note: This also prevents the offset animation from occuring when the user uses a custom message builder
    private func getXOffset() -> CGFloat {
        guard viewModel.messageFrame.width < UIScreen.main.bounds.width else { return .leastNonzeroMagnitude }
        switch viewState {
        case .initial, .row:
            return .leastNonzeroMagnitude
        case .search, .picked:
            if alignment == .left {
                let additionalPadding = max(0, UIScreen.main.bounds.width - maxSelectionRowWidth - leadingPadding)
                return -((UIScreen.main.bounds.width - (additionalPadding + trailingPadding * 3) - (bubbleDiameter * 0.8)) - viewModel.messageFrame.maxX)
            } else {
                let additionalPadding = max(0, UIScreen.main.bounds.width - maxSelectionRowWidth - trailingPadding)
                return viewModel.messageFrame.minX - ((additionalPadding + trailingPadding * 3) + (bubbleDiameter * 0.8))
            }
        }
    }

    /// Calculates the Y axis offset of the ReactionSelectionView for the current ViewState
    /// - Returns: The Y axis offset for the ReactionSelectionView
    /// - Note: If the messageFrame's width is equal to, or larger than, the Screens width then we skip the offset animation
    /// - Note: This also prevents the offset animation from occuring when the user uses a custom message builder
    private func getYOffset() -> CGFloat {
        guard viewModel.messageFrame.width < UIScreen.main.bounds.width else { return .leastNonzeroMagnitude }
        switch viewState {
        case .initial, .row:
            return .leastNonzeroMagnitude
        case .search, .picked:
            return bubbleDiameter / 1.5
        }
    }
}

extension ReactionSelectionView {
    /// ReactionSelectionView View State
    private enum ViewState:Equatable {
        case initial
        /// A horizontal list of default reactions to select from
        /// Placement: above the messageFrame
        case row
        /// A placeholder emoji view that launches the emoji keyboard that allows the sender to select a custom emoji
        /// Placement: At the top corner of the messageFrame or directly above it when using a custom messageBuilder
        case search
        /// A temporary emoji view that animates into it's final position before the message menu is dismissed
        /// Placement: At the top corner of the messageFrame or directly above it when using a custom messageBuilder
        case picked(String)
        
        var needsInteriorShadow:Bool {
            switch self {
            case .row:
                return true
            case .search, .picked, .initial:
                return false
            }
        }
        
        var needsSearchButton:Bool {
            switch self {
            case .row, .search, .initial:
                return true
            case .picked:
                return false
            }
        }
        
        var isPicked:Bool {
            switch self {
            case .picked:
                return true
            default:
                return false
            }
        }
    }
}

internal struct InteriorRadialShadow: ViewModifier {
    var color:Color
    
    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                GeometryReader { proxy in
                    Capsule(style: .continuous)
                        .fill(
                            RadialGradient(gradient: Gradient(colors: [.clear, color]), center: .center, startRadius: proxy.size.width / 2 - 18, endRadius: proxy.size.width / 2 - 5)
                        )
                        .overlay(
                            RadialGradient(gradient: Gradient(colors: [.clear, color]), center: .center, startRadius: proxy.size.width / 2 - 18, endRadius: proxy.size.width / 2 - 5)
                                .clipShape(Capsule(style: .continuous))
                        )
                }
                Capsule(style: .continuous)
                    .stroke(color, lineWidth: 3)
            }
            .allowsHitTesting(false)
        )
    }
}

#Preview {
    VStack {
        ReactionSelectionView(
            viewModel: ChatViewModel(),
            backgroundColor: .gray,
            selectedColor: .blue,
            animation: .linear(duration: 0.2),
            animationDuration: 0.2,
            currentReactions: [
                Reaction(
                    user: .init(
                        id: "123",
                        name: "Tim",
                        avatarURL: nil,
                        isCurrentUser: true
                    ),
                    type: .emoji("❤️")
                ),
                Reaction(
                    user: .init(
                        id: "123",
                        name: "Tim",
                        avatarURL: nil,
                        isCurrentUser: true
                    ),
                    type: .emoji("👍")
                )
            ],
            allowEmojiSearch: true,
            alignment: .left,
            leadingPadding: 20,
            trailingPadding: 20
        ) { selectedEmoji in
            print(selectedEmoji)
        }
    }
    .frame(width: 400, height: 100)
}

extension AnyTransition {
    static var scaleAndFade: AnyTransition {
        .scale.combined(with: .opacity)
    }
}
