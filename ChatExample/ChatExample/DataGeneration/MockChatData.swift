//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import ExyteChat

final class MockChatData: @unchecked Sendable {

    static let shared = MockChatData()

    let tim = User(id: "1", name: "Tim", avatarURL: URL(string: "asset://tim"), isCurrentUser: true)
    let steve = User(id: "2", name: "Steve", avatarURL: URL(string: "asset://steve"), isCurrentUser: false)
    let bob = User(id: "3", name: "Bob", avatarURL: URL(string: "asset://bob"), isCurrentUser: false)

    func randomMessage(senders: [User] = [], date: Date? = nil, text: String? = nil) -> Message {
        let senders = senders.isEmpty ? [tim, steve, bob] : senders
        let sender = senders.random()!
        let date = date ?? Date()
        let attachments = randomAttachments()
        let shouldGenerateText = attachments.isEmpty ? true : Bool.random()

        return Message(
            id: UUID().uuidString,
            user: sender,
            status: sender.isCurrentUser ? .read : nil,
            createdAt: date,
            text: shouldGenerateText ? Lorem.sentence(nbWords: Int.random(in: 3...10), useMarkdown: true) : "",
            attachments: attachments,
            reactions: []
        )
    }

    func randomAttachments() -> [Attachment] {
        guard Int.random(min: 0, max: 10) == 0 else { return [] }
        let count = Int.random(min: 1, max: 5)
        return (0...count).map { _ in randomImageAttachment() }
    }

    func randomImageAttachment() -> Attachment {
        let w = Int.random(in: 200...500)
        let h = Int.random(in: 200...500)
        let url = URL(string: "https://picsum.photos/\(w)/\(h)/")!
        return Attachment(id: UUID().uuidString, thumbnail: url, full: url, type: .image)
    }

    func randomReaction(senders: [User]) -> Reaction {
        let sampleEmojis = ["👍", "👎", "❤️", "🤣", "‼️", "❓", "🥳", "💪", "🔥", "💔", "😭"]
        return Reaction(user: senders.random()!, type: .emoji(sampleEmojis.random()!), status: .sent)
    }

    func reactToMessage(_ msg: Message, senders: [User]) -> Message {
        var msg = msg
        msg.reactions.append(randomReaction(senders: senders))
        return msg
    }
}
