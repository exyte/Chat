//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Combine

final class MockChatInteractor: ChatInteractorProtocol {
    private lazy var chatData = MockChatData()

    private var chatState = CurrentValueSubject<[MockMessage], Never>([])

    func send(message: MockCreateMessage) {
        do {
            let message = try message.toMockMessage(user: chatData.tim)
            chatState.value.append(message)
        } catch {
            // TODO: Create errors in MockCreateMessage.toMockMessage(user:) for immitate error when sending message
            fatalError(error.localizedDescription)
        }
    }
}
