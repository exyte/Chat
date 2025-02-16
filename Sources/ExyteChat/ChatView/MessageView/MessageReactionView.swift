//
//  MessageView+Reaction.swift
//  Chat
//

import SwiftUI

extension MessageView {
    
    @ViewBuilder
    func reactionsView(_ message: Message, maxReactions: Int = 5) -> some View {
        let preparedReactions = prepareReactions(message: message, maxReactions: maxReactions)
        let overflowBubbleText = "+\(message.reactions.count - maxReactions + 1)"
        
        HStack(spacing: -bubbleSize.width / 5) {
            if !message.user.isCurrentUser {
                overflowBubbleView(
                    leadingSpacer: true,
                    needsOverflowBubble: preparedReactions.needsOverflowBubble,
                    text: overflowBubbleText,
                    containsReactionFromCurrentUser: preparedReactions.overflowContainsCurrentUser
                )
            }
            
            ForEach(Array(preparedReactions.reactions.enumerated()), id: \.element) { index, reaction in
                ReactionBubble(reaction: reaction, font: Font(font))
                    .transition(.scaleAndFade)
                    .zIndex(message.user.isCurrentUser ? Double(preparedReactions.reactions.count - index) : Double(index + 1))
                    .sizeGetter($bubbleSize)
            }
            
            if message.user.isCurrentUser {
                overflowBubbleView(
                    leadingSpacer: false,
                    needsOverflowBubble: preparedReactions.needsOverflowBubble,
                    text: overflowBubbleText,
                    containsReactionFromCurrentUser: preparedReactions.overflowContainsCurrentUser
                )
            }
        }
        .padding(.horizontal, -(bubbleSize.width / 2))
        .frame(width: messageSize.width)
        .offset(x: 0, y: -(bubbleSize.height / 1.5))
    }
    
    @ViewBuilder
    func overflowBubbleView(leadingSpacer:Bool, needsOverflowBubble:Bool, text:String, containsReactionFromCurrentUser:Bool) -> some View {
        if leadingSpacer { Spacer() }
        if needsOverflowBubble {
            ReactionBubble(
                reaction: .init(
                    user: .init(
                        id: "null",
                        name: "",
                        avatarURL: nil,
                        isCurrentUser: containsReactionFromCurrentUser
                    ),
                    type: .emoji(text),
                    status: .sent
                ),
                font: .footnote.weight(.light)
            )
            .padding(message.user.isCurrentUser ? .trailing : .leading, -3)
        }
        if !leadingSpacer { Spacer() }
    }
    
    struct PreparedReactions {
        /// Sorted Reactions by most recent -> oldest (trimmed to maxReactions)
        let reactions:[Reaction]
        /// Indicates whether we need to add an overflow bubble (due to the number of Reactions exceeding maxReactions)
        let needsOverflowBubble:Bool
        /// Indicates whether the clipped reactions (oldest reactions beyond maxReaction) contain a reaction from the current user
        /// - Note: This value is used to color the background of the overflow bubble
        let overflowContainsCurrentUser:Bool
    }
    
    /// Orders the reactions by most recent to oldest, reverses their layout based on alignment and determines if an overflow bubble is necessary
    private func prepareReactions(message:Message, maxReactions:Int) -> PreparedReactions {
        guard maxReactions > 1, !message.reactions.isEmpty else {
            return .init(reactions: [], needsOverflowBubble: false, overflowContainsCurrentUser: false)
        }
        // If we have more reactions than maxReactions, then we'll need an overflow bubble
        let needsOverflowBubble = message.reactions.count > maxReactions
        // Sort all reactions by most recent -> oldest
        var reactions = Array(message.reactions.sorted(by: { $0.createdAt > $1.createdAt }))
        // Check if our current user has a reaction in the overflow reactions (used for coloring the overflow bubble)
        var overflowContainsCurrentUser: Bool = false
        if needsOverflowBubble {
           overflowContainsCurrentUser = reactions[min(reactions.count, maxReactions)...].contains(where: {  $0.user.isCurrentUser })
        }
        // Trim the reactions array if necessary
        if needsOverflowBubble { reactions = Array(reactions.prefix(maxReactions - 1)) }
        
        return .init(
            reactions: message.user.isCurrentUser ? reactions : reactions.reversed(),
            needsOverflowBubble: needsOverflowBubble,
            overflowContainsCurrentUser: overflowContainsCurrentUser
        )
    }
}

struct ReactionBubble: View {
    
    @Environment(\.chatTheme) var theme
    
    let reaction: Reaction
    let font: Font
    
    @State private var phase = 0.0
    
    var fillColor: Color {
        switch reaction.status {
        case .sending, .sent, .read:
            return reaction.user.isCurrentUser ? theme.colors.messageMyBG : theme.colors.messageFriendBG
        case .error:
            return .red
        }
    }
    
    var opacity: Double {
        switch reaction.status {
        case .sent, .read:
            return 1.0
        case .sending, .error:
            return 0.7
        }
    }
    
    var body: some View {
        Text(reaction.emoji ?? "?")
            .font(font)
            .opacity(opacity)
            .foregroundStyle(reaction.user.isCurrentUser ? theme.colors.messageMyText : theme.colors.messageFriendText)
            .padding(6)
            .background(
                ZStack {
                    Circle()
                        .fill(fillColor)
                    // If the reaction is in flight, animate the stroke
                    if reaction.status == .sending {
                        Circle()
                            .stroke(style: .init(lineWidth: 2, lineCap: .round, dash: [100, 50], dashPhase: phase))
                            .fill(theme.colors.messageFriendBG)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                                    phase -= 150
                                }
                            }
                    // Otherwise just stroke the circle normally
                    } else {
                        Circle()
                            .stroke(style: .init(lineWidth: 1))
                            .fill(theme.colors.mainBG)
                    }
                }
            )
    }
}
