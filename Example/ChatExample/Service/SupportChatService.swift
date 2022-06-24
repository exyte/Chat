//
//  Created by Alex.M on 24.06.2022.
//

import Foundation
import Combine

enum SupportChatMessageSender: Equatable {
    case user
    case support(name: String)
    case system
}

struct SupportChatMessage {
    let message: String
    let sender: SupportChatMessageSender
    let createdAt: Date
}

class SupportChatService {
    var messages: AnyPublisher<[SupportChatMessage], Never> {
        storedMessages.eraseToAnyPublisher()
    }

    private var storedMessages = CurrentValueSubject<[SupportChatMessage], Never>([])
    private var userMessages = PassthroughSubject<String, Never>()
    private lazy var sharedUserMessages: AnyPublisher<String, Never> = userMessages.share().eraseToAnyPublisher()
    private var supporterNameSubject = CurrentValueSubject<String?, Never>(nil)
    private var findSupporterInProgress: Bool = false
    private var subscriptions = Set<AnyCancellable>()

    private var countSupporterAnswers = 0

    init() {
        sharedUserMessages
            .map {
                SupportChatMessage(message: $0, sender: .user, createdAt: Date())
            }
            .sink { [weak self] message in
                guard let self = self else { return }
                self.storedMessages.value.append(message)
                if !self.findSupporterInProgress && self.supporterNameSubject.value == nil {
                    self.findSupporter()
                }
            }
            .store(in: &subscriptions)

        sharedUserMessages
            .combineLatest(supporterNameSubject)
            .debounce(for: 2.0, scheduler: DispatchQueue.main)
            .compactMap { (_, supporter) -> String? in
                if let supporter = supporter {
                    return supporter
                } else {
                    return nil
                }
            }
            .sink { [weak self] name in
                self?.generateAnswer(name: name)
            }
            .store(in: &subscriptions)
    }

    func send(message: String) {
        userMessages.send(message)
    }
}

private extension SupportChatService {
    func findSupporter() {
        findSupporterInProgress = true
        inNearFuture(range: 2..<5) { [weak self] in
            self?.supporterNameSubject.value = ["Tim", "Steave", "Tom", "Jack", "Jhon"].randomElement() ?? "Jhon"
            self?.findSupporterInProgress = false
        }
        storedMessages.value.append(
            SupportChatMessage(
                message: "We are looking for an operator to help. Please wait a couple of minutes.",
                sender: .system,
                createdAt: Date()
            )
        )
    }

    func finishSupport() {
        supporterNameSubject.value = nil
        storedMessages.value.append(
            SupportChatMessage(
                message: "Operator finish conversation.",
                sender: .system,
                createdAt: Date()
            )
        )
    }

    func generateAnswer(name: String) {
        inNearFuture(range: 4..<7) { [name, weak self] in
            guard let self = self else { return }
            if Int.random(in: 1..<10) <= self.countSupporterAnswers {
                self.storedMessages.value.append(
                    SupportChatMessage(
                        message: "Sorry we can't help now. Please contact with us later.",
                        sender: .support(name: name),
                        createdAt: Date()
                    )
                )
                self.finishSupport()
                self.countSupporterAnswers = 0
            } else {
                self.storedMessages.value.append(
                    SupportChatMessage(
                        message: "Question or explanation",
                        sender: .support(name: name),
                        createdAt: Date()
                    )
                )
                self.countSupporterAnswers += 1
            }
        }
    }
}

func inNearFuture(queue: DispatchQueue = .main, range: Range<Double> = 1.0..<5.0, action: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + .random(in: range), execute: action)
}
