//
//  MessageMenu+ReactionOverview.swift
//  Chat
//

import SwiftUI

struct ReactionOverview: View {
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @StateObject var viewModel: ChatViewModel
    
    let message: Message
    let backgroundColor: Color
    let padding: CGFloat = 16
    
    struct SortedReaction:Identifiable {
        var id: String { reaction.toString }
        let reaction: ReactionType
        let users: [User]
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: padding) {
                Spacer()
                ForEach( sortReactions() ) { reaction in
                    reactionUserView(reaction: reaction)
                        .padding(padding / 2)
                }
                Spacer()
            }
            .frame(minWidth: UIScreen.main.bounds.width - (padding * 2))
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(backgroundColor)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .padding(padding)
    }
    
    @ViewBuilder
    func reactionUserView(reaction:SortedReaction) -> some View {
        VStack {
            Text(reaction.reaction.toString)
                .font(.title3)
                .background(
                    emojiBackgroundView()
                        .opacity(0.5)
                        .padding(-10)
                )
                .padding(.top, 8)
                .padding(.bottom)
                                         
            HStack(spacing: -14) {
                ForEach(reaction.users) { user in
                    AvatarView(url: user.avatarURL, avatarSize: 32)
                        .contentShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(style: .init(lineWidth: 1))
                                .foregroundStyle(backgroundColor)
                        )
                }
            }
        }
    }
    
    @ViewBuilder
    func emojiBackgroundView() -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color(UIColor.systemBackground))
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: proxy.size.width / 4, height: proxy.size.width / 4)
                    .offset(y: proxy.size.height / 2)
            }
        }
        .compositingGroup()
    }
    
    private func sortReactions() -> [SortedReaction] {
        let mostRecent = message.reactions.sorted { $0.createdAt < $1.createdAt }
        let orderedEmojis = mostRecent.map(\.emoji)
        return Set(message.reactions.compactMap(\.emoji)).sorted(by: {
            orderedEmojis.firstIndex(of: $0)! < orderedEmojis.firstIndex(of: $1)!
        }).map { emoji in
            let users = mostRecent.filter { $0.emoji == emoji }
            return SortedReaction(
                reaction: .emoji(emoji),
                users: users.map(\.user)
            )
        }
    }
}

#Preview {
    let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)
    let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
    let sally = User(id: "sally", name: "Sally", avatarURL: nil, isCurrentUser: false)
    
    ReactionOverview(
        viewModel: ChatViewModel(),
        message: .init(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: "An example message of great importance",
            reactions: [
                Reaction(user: john, createdAt: Date.now.addingTimeInterval(-80), type: .emoji("🔥")),
                Reaction(user: stan, createdAt: Date.now.addingTimeInterval(-70), type: .emoji("🥳")),
                Reaction(user: john, createdAt: Date.now.addingTimeInterval(-60), type: .emoji("🔌")),
                Reaction(user: john, createdAt: Date.now.addingTimeInterval(-50), type: .emoji("🧠")),
                Reaction(user: john, createdAt: Date.now.addingTimeInterval(-40), type: .emoji("🥳")),
                Reaction(user: stan, createdAt: Date.now.addingTimeInterval(-30), type: .emoji("🔌")),
                Reaction(user: stan, createdAt: Date.now.addingTimeInterval(-20), type: .emoji("🧠")),
                Reaction(user: sally, createdAt: Date.now.addingTimeInterval(-10), type: .emoji("🧠"))
            ]
        ),
        backgroundColor: .black //Color(UIColor.secondarySystemBackground)
    )
}
