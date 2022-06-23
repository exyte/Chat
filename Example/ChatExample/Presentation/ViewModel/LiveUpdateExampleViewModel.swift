//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import Chat

final class LiveUpdateExampleViewModel: AbstractExampleViewModel {
    private lazy var chatService = MockChatService()
    private lazy var endlessMessagesGenerator = EndlessMessagesGenerator()

    private var lastMessageId = 0

    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        endlessMessagesGenerator.messages
            .map(mapMyMessages)
            .print("Messages")
            .assign(to: &$messages)
    }

    override func send(draft: DraftMessage) {
//        chatService.send(message: draft.text)
    }
    
    override func onStart() {
//        chatService.loadMessages()
//            .print("Load messages")
//            .sink { completion in
//                print(completion)
//            } receiveValue: { _ in
//                // Do nothing
//            }
//            .store(in: &subscriptions)
    }
}

private extension LiveUpdateExampleViewModel {
    var nextMessageId: Int {
        defer {
            lastMessageId += 1
        }
        return lastMessageId + 1
    }

    func mapMyMessages(_ messages: [MyMessage]) -> [Message] {
        messages.map {
            Message(
                id: nextMessageId,
                user: getUser(from: $0.sender),
                text: $0.text
            )
        }
    }

    func getUser(from id: Int) -> User {
        switch id {
        case 11:
            return .steve
        case 42:
            return .tim
        default:
            fatalError()
        }
    }
}
