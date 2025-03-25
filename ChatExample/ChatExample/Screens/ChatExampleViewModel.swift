//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import ExyteChat

final class ChatExampleViewModel: ObservableObject, ReactionDelegate {

    @Published var messages: [Message] = []
    
    var chatTitle: String {
        interactor.otherSenders.count == 1 ? interactor.otherSenders.first!.name : "Group chat"
    }
    var chatStatus: String {
        interactor.otherSenders.count == 1 ? "online" : "\(interactor.senders.count) members"
    }
    var chatCover: URL? {
        interactor.otherSenders.count == 1 ? interactor.otherSenders.first!.avatar : nil
    }

    private let interactor: any ChatInteractorProtocol
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: any ChatInteractorProtocol = MockChatInteractor()) {
        self.interactor = interactor
    }

    func send(draft: DraftMessage) {
        interactor.send(draftMessage: draft)
    }
    
    func remove(messageID: String) {
        interactor.remove(messageID: messageID)
    }

    func didReact(to message: Message, reaction draftReaction: DraftReaction) {
        interactor.add(draftReaction: draftReaction, to: draftReaction.messageID)
    }

    func onStart() {
        interactor.messages
            .compactMap { messages in
                messages.map { $0.toChatMessage() }
            }
            .assign(to: &$messages)

        interactor.connect()
    }

    func onStop() {
        interactor.disconnect()
    }

    func loadMoreMessage(before message: Message) {
        interactor.loadNextPage()
            .sink { _ in }
            .store(in: &subscriptions)
    }
}
