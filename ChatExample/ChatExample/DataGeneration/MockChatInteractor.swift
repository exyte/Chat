//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import ExyteChat
import ExyteMediaPicker

final actor MockChatInteractor {

    private let chatData = MockChatData.shared

    @Published private(set) var messages: [Message] = []

    private let isActive: Bool
    private var isLoading = false
    private var newestDate = Date().addingTimeInterval(-2*60*60*24)
    private var oldestDate = Date().addingTimeInterval(-3*60*60*24)

    var senders: [User] {
        var members = [chatData.steve, chatData.tim]
        if isActive { members.append(chatData.bob) }
        return members
    }

    var otherSenders: [User] {
        senders.filter { !$0.isCurrentUser }
    }

    init(isActive: Bool = false) {
        self.isActive = isActive
        Task { await self.generateFirstPage() }
    }

    func generateFirstPage() async {
        self.messages = generateStartMessages()
    }

    func send(draftMessage: DraftMessage) async {
        if draftMessage.id != nil {
            guard let index = messages.firstIndex(where: { $0.id == draftMessage.id }) else { return }
            messages.remove(at: index)
        }

        var status: Message.Status = .sent
        if Int.random(min: 0, max: 20) == 0 {
            status = .error(draftMessage)
        }
        let message = await buildMessage(from: draftMessage, user: chatData.tim, status: status)
        messages.append(message)
    }

    func remove(messageID: String) {
        messages.removeAll(where: { $0.id == messageID })
    }

    func add(draftReaction: DraftReaction, to messageID: String) {
        guard let matchIndex = messages.firstIndex(where: { $0.id == messageID }) else {
            print("No Match for Reaction")
            return
        }
        let reaction = Reaction(user: chatData.tim, type: draftReaction.type)
        messages[matchIndex].reactions.append(reaction)
        delayUpdateReactionStatus(messageID: messageID, reactionID: reaction.id)
    }

    func delayUpdateReactionStatus(messageID: String, reactionID: String) {
        Task {
            let delay = UInt64.random(in: 1000...3500) * 1_000_000
            try? await Task.sleep(nanoseconds: delay)
            updateReactionStatus(messageID: messageID, reactionID: reactionID)
        }
    }

    func updateReactionStatus(messageID: String, reactionID: String) {
        guard let msgIndex = messages.firstIndex(where: { $0.id == messageID }) else {
            print("No Match for Message"); return
        }
        guard let reactionIndex = messages[msgIndex].reactions.firstIndex(where: { $0.id == reactionID }) else {
            print("No Match for Reaction"); return
        }
        var status: Reaction.Status = .sent
        if Int.random(min: 0, max: 20) == 0 {
            let r = messages[msgIndex].reactions[reactionIndex]
            status = .error(.init(id: r.id, messageID: messageID, createdAt: r.createdAt, type: r.type))
        }
        messages[msgIndex].reactions[reactionIndex].status = status
    }

    func timerTick() {
        updateSendingStatuses()
        if isActive { generateNewMessage() }
    }

    func loadNewerMessagesPage() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        messages.append(contentsOf: generateStartMessages(older: false))
        isLoading = false
    }

    func loadOlderMessagesPage() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        messages.insert(contentsOf: generateStartMessages(), at: 0)
        isLoading = false
    }

    func toMessages() -> [Message] {
        messages
    }
}

// MARK: - Private helpers

private extension MockChatInteractor {

    func generateStartMessages(older: Bool = true) -> [Message] {
        let date = older ? oldestDate : newestDate
        let startOfDay = Calendar.current.startOfDay(for: date)
        defer {
            if older {
                oldestDate = oldestDate.addingTimeInterval(-(60*60*24))
            } else {
                newestDate = newestDate.addingTimeInterval(60*60*24)
            }
        }
        return (0...20)
            .map { _ in
                let msgDate = startOfDay.addingTimeInterval(TimeInterval(Int.random(in: 0..<86400)))
                var msg = chatData.randomMessage(senders: senders, date: msgDate)
                if Int.random(in: 0...4) == 0 { msg = chatData.reactToMessage(msg, senders: senders) }
                return msg
            }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func generateNewMessage() {
        let idx = Int.random(min: 1, max: 10)
        if idx <= 3, messages.count >= idx {
            let msgIndex = messages.count - idx
            messages[msgIndex] = chatData.reactToMessage(messages[msgIndex], senders: otherSenders)
        } else {
            messages.append(chatData.randomMessage(senders: otherSenders))
        }
    }

    func updateSendingStatuses() {
        messages = messages.map { msg in
            var msg = msg
            switch msg.status {
            case .sending: msg.status = .sent
            case .sent: msg.status = .read
            default: break
            }
            return msg
        }
    }
}

// MARK: - Message building

extension MockChatInteractor {

    func buildMessage(from draftMessage: DraftMessage, user: User, status: Message.Status) async -> Message {
        Message(
            id: draftMessage.id ?? UUID().uuidString,
            user: user,
            status: user.isCurrentUser ? status : nil,
            createdAt: draftMessage.createdAt,
            text: draftMessage.text,
            attachments: await makeAttachments(draftMessage),
            reactions: [],
            recording: draftMessage.recording,
            replyMessage: draftMessage.replyMessage
        )
    }

    func makeAttachments(_ draftMessage: DraftMessage) async -> [Attachment] {
        await draftMessage.medias
            .asyncMap { (media: Media) -> (Media, URL?, URL?) in
                (media, await media.getThumbnailURL(), await media.getURL())
            }
            .filter { $0.1 != nil && $0.2 != nil }
            .map { media, thumb, full in
                Attachment(
                    id: media.id.uuidString,
                    thumbnail: thumb!,
                    full: full!,
                    type: AttachmentType(mediaType: media.type)
                )
            }
    }
}
