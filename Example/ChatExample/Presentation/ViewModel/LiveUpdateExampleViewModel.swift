//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import Chat

final class LiveUpdateExampleViewModel: AbstractExampleViewModel {
    private let interactor: ChatInteractorProtocol
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: ChatInteractorProtocol = MockChatInteractor()) {
        self.interactor = interactor
    }

    override func send(draft: DraftMessage) {
        interactor.send(message: draft.toMockCreateMessage())
    }
    
    override func onStart() {
    }
}

struct MockCreateMessage {
    let text: String
    let createdAt: Date
}

extension MockCreateMessage {
    func toMockMessage(user: MockUser) throws -> MockMessage {
        MockMessage(
            uid: .random(),
            sender: user,
            createdAt: createdAt,
            text: text
        )
    }
}

extension DraftMessage {
    func toMockCreateMessage() -> MockCreateMessage {
        MockCreateMessage(
            text: text,
            createdAt: createdAt
        )
    }
}
