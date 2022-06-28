//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Combine

final class MockChatInteractor: ChatInteractorProtocol {
    private lazy var chatData = MockChatData()

    private lazy var chatState = CurrentValueSubject<[MockMessage], Never>(generateStartMessages())
    private lazy var sharedState = chatState.share()

    private var isLoading = false

    private var subscriptions = Set<AnyCancellable>()

    var messages: AnyPublisher<[MockMessage], Never> {
        sharedState.eraseToAnyPublisher()
    }

    /// TODO: Generate error with random chance
    /// TODO: Save images from url to files. Imitate upload process
    func send(message: MockCreateMessage) {
        let message = message.toMockMessage(user: chatData.tim)
        chatState.value.append(message)
    }

    func connect() {
        Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.generateNewMessage()
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
        (0...10).map { index in
            chatData.randomMessage()
        }
    }

    func generateNewMessage() {
        let message = chatData.randomMessage(senders: [chatData.steve, chatData.emma])
        chatState.value.append(message)
    }
}
