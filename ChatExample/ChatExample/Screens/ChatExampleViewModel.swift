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

    var tableTransaction: TableUpdateTransaction?
    var scrollToParams: ScrollToParams?

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
            self.messages = await self.convertMessages()
        }
    }
    
    func remove(messageID: String) {
        Task {
            await interactor.remove(messageID: messageID)
            self.messages = await self.convertMessages()
        }
    }

    nonisolated func didReact(to message: Message, reaction draftReaction: DraftReaction) {
        Task {
            await interactor.add(draftReaction: draftReaction, to: draftReaction.messageID)
        }
    }

    func onStart() {
        Task {
            self.messages = await self.convertMessages()
            connect()
        }
    }

    func connect() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            Task { @MainActor in
                await self.interactor.timerTick()
                self.messages = await self.convertMessages()
            }
        }
    }

    func onStop() {
        timer?.invalidate()
    }

    func loadNewerMessagesPage() async {
        guard let tableTransaction, let id = messages.last?.id else { return }
        await interactor.loadNewerMessagesPage()
        let messages = await convertMessages()
        await tableTransaction(animated: false) {
            print(id, self.messages.last?.text)
            self.messages = messages
            self.scrollToParams = .init(messageID: id, position: .bottom, offset: -50)
        }
        self.scrollToParams = nil
    }

    func loadOlderMessagesPage() async {
        print("load more")
        guard let tableTransaction else { return }
        await interactor.loadOlderMessagesPage()
        let messages = await convertMessages()
        await tableTransaction(animated: false) {
            self.messages = messages
        }
    }

    func convertMessages() async -> [Message] {
        await interactor.messages.compactMap { $0.toChatMessage() }
    }
}
