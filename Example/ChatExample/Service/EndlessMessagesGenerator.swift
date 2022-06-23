//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine

final class EndlessMessagesGenerator {
    var messages: AnyPublisher<[MyMessage], Never> {
        generatedMessages.eraseToAnyPublisher()
    }

    private var generatedMessages = CurrentValueSubject<[MyMessage], Never>([])
    private var subscriptions = Set<AnyCancellable>()

    init() {
        Timer.publish(every: 1.5, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.generatedMessages.value.append(self.generateMessage())
            }
            .store(in: &subscriptions)
    }
}

private extension EndlessMessagesGenerator {
    func generateMessage() -> MyMessage {
        let num = generatedMessages.value.count + 1
        return MyMessage(
            text: "Message #\(num)",
            sender: Bool.random() ? 11 : 42
        )
    }
}
