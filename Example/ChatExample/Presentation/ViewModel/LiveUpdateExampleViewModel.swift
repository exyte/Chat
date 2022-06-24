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

    override func send(draft: DraftMessage) {}
    
    override func onStart() {
        endlessMessagesGenerator.messages
            .compactMap { [weak self] in
                self?.mapMyMessages($0)
            }
            .assign(to: &$messages)
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
