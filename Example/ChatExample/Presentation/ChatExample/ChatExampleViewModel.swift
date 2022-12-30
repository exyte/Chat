//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import Chat

final class ChatExampleViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private let interactor: ChatInteractorProtocol
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: ChatInteractorProtocol = MockChatInteractor()) {
        self.interactor = interactor
    }

    func send(draft: DraftMessage) {
        interactor.send(message: draft.toMockCreateMessage())
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

struct MockCreateMessage {
    let uid: String?
    let text: String
    let createdAt: Date
    let images: [MockImage]
}

extension MockCreateMessage {
    func toMockMessage(user: MockUser, status: Message.Status = .read) -> MockMessage {
        MockMessage(
            uid: UUID().uuidString,
            sender: user,
            createdAt: createdAt,
            status: user.isCurrentUser ? status : nil,
            text: text
        )
    }
}

extension DraftMessage {
    func makeMockImages() -> [MockImage] {
        attachments
            .compactMap { $0 as? ImageAttachment }
            .map {
                MockImage(thumbnail: $0.thumbnail, full: $0.full)
            }
    }

    func toMockCreateMessage() -> MockCreateMessage {
        MockCreateMessage(
            uid: id,
            text: text,
            createdAt: createdAt,
            images: makeMockImages()
        )
    }
}
