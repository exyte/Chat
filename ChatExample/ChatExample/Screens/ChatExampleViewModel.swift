//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import ExyteChat

@MainActor
final class ChatExampleViewModel: ObservableObject, ReactionDelegate {

    @Published var messages: [Message] = []

    var tableTransaction: TableUpdateTransaction?
    var scrollToParams: ScrollToParams?

    var newPagesCount = 0
    let maxNewPagesCount = 2

    private let interactor = MockChatInteractor(isActive: false)

    init() {
        updateMessages()
    }

    func send(draft: DraftMessage) {
        Task {
            await interactor.send(draftMessage: draft)
            updateMessages()
        }
    }
    
    func remove(messageID: String) {
        Task {
            await interactor.remove(messageID: messageID)
            updateMessages()
        }
    }

    nonisolated func didReact(to message: Message, reaction draftReaction: DraftReaction) {
        Task {
            await interactor.add(draftReaction: draftReaction, to: draftReaction.messageID)
        }
    }

    func loadNewerMessagesPage() async {
        guard let tableTransaction else { return }
        newPagesCount += 1
        await interactor.loadNewerMessagesPage()
        let messages = await interactor.toMessages()
        await tableTransaction(animationMode: .keepStable) {
            self.messages = messages
        }
    }

    func loadOlderMessagesPage() async {
        guard let tableTransaction else { return }
        await interactor.loadOlderMessagesPage()
        let messages = await interactor.toMessages()
        await tableTransaction(animated: false) {
            self.messages = messages
        }
    }

    func updateMessages() {
        Task {
            self.messages = await interactor.toMessages()
        }
    }
}
