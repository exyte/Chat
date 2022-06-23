//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine

final class MockChatService: ChatServiceProtocol {
    var pageMessageCount: Int

    var messages: AnyPublisher<[MyMessage], Never> {
        fetchedMessages.eraseToAnyPublisher()
    }

    private lazy var messagesStack = generateMessages()
    private var fetchedMessages = CurrentValueSubject<[MyMessage], Never>([])

    init(pageMessageCount: Int = 15) {
        self.pageMessageCount = pageMessageCount
    }

    func send(message: String) {
        let forSend = MyMessage(text: message, sender: 42)
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 0.5...3.0)) { [weak self] in
            self?.fetchedMessages.value.append(forSend)
        }
    }

    func loadMessages() -> Future<Void, ChatError> {
        Future { [weak self] promise in
            guard let self = self,
                  !self.messagesStack.isEmpty
            else {
                promise(.failure(.unknown(source: nil)))
                return
            }

            let messages = self.messagesStack.suffix(self.pageMessageCount)
            self.messagesStack.removeLast(self.pageMessageCount)

            self.fetchedMessages.value.append(contentsOf: messages)
            promise(.success(()))
        }
    }
}

private extension MockChatService {
    func generateMessages() -> [MyMessage] {
        return [
            MyMessage(text: "[1] Do you think coming here will help you not to be sad?", sender: 11),
            MyMessage(text: "[1] We were discussing you -- not me.", sender: 42),
            MyMessage(text: "[1] Does someone else believe I -- not you?", sender: 11),
            MyMessage(text: "[1] You're not really talking about me -- are you?", sender: 42),
            MyMessage(text: "[1] Do you sometimes wish you were not really talking about you -- are me?", sender: 11),
            MyMessage(text: "[1] Why do you think I -- are you?", sender: 42),
            MyMessage(text: "[1] Oh, I?", sender: 11),
            MyMessage(text: "[1] Do you say you for some special reason?", sender: 42),
            MyMessage(text: "[1] You're not really talking about me -- are you?", sender: 11),
            MyMessage(text: "[1] What makes you think I am not really talking about you -- are me?", sender: 42),
            MyMessage(text: "[2] Do you think coming here will help you not to be sad?", sender: 11),
            MyMessage(text: "[2] We were discussing you -- not me.", sender: 42),
            MyMessage(text: "[2] Does someone else believe I -- not you?", sender: 11),
            MyMessage(text: "[2] You're not really talking about me -- are you?", sender: 42),
            MyMessage(text: "[2] Do you sometimes wish you were not really talking about you -- are me?", sender: 11),
            MyMessage(text: "[2] Why do you think I -- are you?", sender: 42),
            MyMessage(text: "[2] Oh, I?", sender: 11),
            MyMessage(text: "[2] Do you say you for some special reason?", sender: 42),
            MyMessage(text: "[2] You're not really talking about me -- are you?", sender: 11),
            MyMessage(text: "[2] What makes you think I am not really talking about you -- are me?", sender: 42),
            MyMessage(text: "[3] Do you think coming here will help you not to be sad?", sender: 11),
            MyMessage(text: "[3] We were discussing you -- not me.", sender: 42),
            MyMessage(text: "[3] Does someone else believe I -- not you?", sender: 11),
            MyMessage(text: "[3] You're not really talking about me -- are you?", sender: 42),
            MyMessage(text: "[3] Do you sometimes wish you were not really talking about you -- are me?", sender: 11),
            MyMessage(text: "[3] Why do you think I -- are you?", sender: 42),
            MyMessage(text: "[3] Oh, I?", sender: 11),
            MyMessage(text: "[3] Do you say you for some special reason?", sender: 42),
            MyMessage(text: "[3] You're not really talking about me -- are you?", sender: 11),
            MyMessage(text: "[3] What makes you think I am not really talking about you -- are me?", sender: 42),
        ]
    }
}
