//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import Chat

final class ChatExampleViewModel: ObservableObject {
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
    let createdAt: Date

    let text: String
    let images: [MockImage]
    let recording: Recording?
}

extension MockCreateMessage {
    func toMockMessage(user: MockUser, status: Message.Status = .read) -> MockMessage {
        MockMessage(
            uid: UUID().uuidString,
            sender: user,
            createdAt: createdAt,
            status: user.isCurrentUser ? status : nil,
            text: text,
            images: images,
            recording: recording
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
            createdAt: createdAt,
            text: text,
            images: makeMockImages(),
            recording: recording
        )
    }
}
