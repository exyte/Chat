//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Combine
import ExyteChat

final class MockChatInteractor: ChatInteractorProtocol {
    private lazy var chatData = MockChatData()

    private lazy var chatState = CurrentValueSubject<[MockMessage], Never>(generateStartMessages())
    private lazy var sharedState = chatState.share()

    private let isActive: Bool
    private var isLoading = false
    private var lastDate = Date()

    private var subscriptions = Set<AnyCancellable>()

    var messages: AnyPublisher<[MockMessage], Never> {
        sharedState.eraseToAnyPublisher()
    }
    
    var senders: [MockUser] {
        var members = [chatData.steve, chatData.tim]
        if isActive { members.append(chatData.bob) }
        return members
    }
    
    var otherSenders: [MockUser] {
        senders.filter { !$0.isCurrentUser }
    }
    
    init(isActive: Bool = false) {
        self.isActive = isActive
    }

    /// TODO: Generate error with random chance
    /// TODO: Save images from url to files. Imitate upload process
    func send(draftMessage: ExyteChat.DraftMessage) {
        if draftMessage.id != nil {
            guard let index = chatState.value.firstIndex(where: { $0.uid == draftMessage.id }) else {
                // TODO: Create error
                return
            }
            chatState.value.remove(at: index)
        }

        Task {
            var status: Message.Status = .sending
            if Int.random(min: 0, max: 20) == 0 {
                status = .error(draftMessage)
            }
            let message = await draftMessage.toMockMessage(user: chatData.tim, status: status)
            DispatchQueue.main.async { [weak self] in
                self?.chatState.value.append(message)
            }
        }
    }
    
    func remove(messageID: String) {
        DispatchQueue.main.async { [weak self] in
            self?.chatState.value.removeAll(where: { $0.uid == messageID })
        }
    }
    
    /// Adds a reaction to an existing message
    func add(draftReaction: ExyteChat.DraftReaction, to messageID: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let matchIndex = self.chatState.value.firstIndex(where: { $0.uid == messageID }) {
                let originalMessage = self.chatState.value[matchIndex]
                let reaction = Reaction(user: self.chatData.tim.toChatUser(), type: draftReaction.type)
                let newMessage = MockMessage(
                    uid: originalMessage.uid,
                    sender: originalMessage.sender,
                    createdAt: originalMessage.createdAt,
                    status: originalMessage.status,
                    text: originalMessage.text,
                    images: originalMessage.images,
                    videos: originalMessage.videos,
                    reactions: originalMessage.reactions + [reaction],
                    recording: originalMessage.recording,
                    replyMessage: originalMessage.replyMessage
                )
                print("Setting Reaction")
                self.chatState.value[matchIndex] = newMessage
                
                // Update our message reaction status after a random delay...
                delayUpdateReactionStatus(messageID: messageID, reactionID: reaction.id)
                
            } else {
                print("No Match for Reaction")
            }
        }
    }

    /// Updates a reaction's status after a random amount of time
    func delayUpdateReactionStatus(messageID: String, reactionID: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.random(in: 500...2500))) { [weak self] in
            guard let self else { return }
            if let matchIndex = self.chatState.value.firstIndex(where: { $0.uid == messageID }) {
                let originalMessage = self.chatState.value[matchIndex]
                if let reactionIndex = originalMessage.reactions.firstIndex(where: { $0.id == reactionID }) {
                    let originalReaction = originalMessage.reactions[reactionIndex]
                    
                    var reactions = originalMessage.reactions
                    var status:Reaction.Status = .sent
                    if Int.random(min: 0, max: 2) == 0 {
                        status = .error(.init(id: originalReaction.id, messageID: originalMessage.uid, createdAt: originalReaction.createdAt, type: originalReaction.type))
                    }
                    reactions[reactionIndex] = .init(id: originalReaction.id, user: originalReaction.user, createdAt: originalReaction.createdAt, type: originalReaction.type, status: status)
                    
                    let newMessage = MockMessage(
                        uid: originalMessage.uid,
                        sender: originalMessage.sender,
                        createdAt: originalMessage.createdAt,
                        status: originalMessage.status,
                        text: originalMessage.text,
                        images: originalMessage.images,
                        videos: originalMessage.videos,
                        reactions: reactions,
                        recording: originalMessage.recording,
                        replyMessage: originalMessage.replyMessage
                    )
                    
                    self.chatState.value[matchIndex] = newMessage
                } else {
                    print("No Match for Reaction")
                }
            } else {
                print("No Match for Message")
            }
        }
    }

    func connect() {
        Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSendingStatuses()
                if self?.isActive ?? false {
                    self?.generateNewMessage()
                }
            }
            .store(in: &subscriptions)
    }

    func disconnect() {
        subscriptions.removeAll()
    }

    func loadNextPage() -> Future<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self = self, !self.isLoading else {
                promise(.success(false))
                return
            }
            self.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                let messages = self.generateStartMessages()
                self.chatState.value = messages + self.chatState.value
                self.isLoading = false
                promise(.success(true))
            }
        }
    }
}

private extension MockChatInteractor {
    func generateStartMessages() -> [MockMessage] {
        defer {
            lastDate = lastDate.addingTimeInterval(-(60*60*24))
        }
        return (0...10)
            .map { index in
                chatData.randomMessage(senders: senders, date: lastDate.randomTime())
            }
            .sorted { lhs, rhs in
                lhs.createdAt < rhs.createdAt
            }
    }

    func generateNewMessage() {
        let message = chatData.randomMessage(senders: otherSenders)
        chatState.value.append(message)
    }

    func updateSendingStatuses() {
        let updated = chatState.value.map {
            var message = $0
            if message.status == .sending {
                message.status = .sent
            } else if message.status == .sent {
                message.status = .read
            }
            return message
        }
        chatState.value = updated
    }
}
