//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import ExyteChat

@MainActor
final class ChatExampleViewModel: ObservableObject, ReactionDelegate {

    @Published var messages: [Message] = []

    @Published var chatTitle: String = ""
    @Published var chatStatus: String = ""
    @Published var chatCover: URL?

    private let interactor: MockChatInteractor
    private var timer: Timer?

    init(interactor: MockChatInteractor = MockChatInteractor()) {
        self.interactor = interactor

        Task {
            let senders = await interactor.otherSenders
            self.chatTitle = senders.count == 1 ? senders.first!.name : "Group chat"
            self.chatStatus = senders.count == 1 ? "online" : "\(senders.count + 1) members"
            self.chatCover = senders.count == 1 ? senders.first!.avatar : nil
        }
    }

    func send(draft: DraftMessage) {
        Task {
            await interactor.send(draftMessage: draft)
            self.updateMessages()
        }
    }
    
    func remove(messageID: String) {
        Task {
            await interactor.remove(messageID: messageID)
            self.updateMessages()
        }
    }

    nonisolated func didReact(to message: Message, reaction draftReaction: DraftReaction) {
        Task {
            await interactor.add(draftReaction: draftReaction, to: draftReaction.messageID)
        }
    }

    func onStart() {
        Task {
            self.updateMessages()
            connect()
        }
    }

    func connect() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            Task {
                await self.interactor.timerTick()
                await self.updateMessages()
            }
        }
    }

    func onStop() {
        timer?.invalidate()
    }

    func loadMoreMessage(before message: Message) {
        Task {
            await interactor.loadNextPage()
            updateMessages()
        }
    }

    func updateMessages() {
        Task {
            self.messages = await interactor.messages.compactMap { $0.toChatMessage() }
        }
    }
}
