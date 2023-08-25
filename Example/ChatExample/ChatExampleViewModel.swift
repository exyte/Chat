//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine
import ExyteChat
import ExyteMediaPicker

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
        interactor.send(draftMessage: draft)
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

extension DraftMessage {
    func makeMockImages() async -> [MockImage] {
        await medias
            .filter { $0.type == .image }
            .asyncMap { (media : Media) -> (Media, URL?, URL?) in
                (media, await media.getThumbnailURL(), await media.getURL())
            }
            .filter { (media: Media, thumb: URL?, full: URL?) -> Bool in
                thumb != nil && full != nil
            }
            .map { media, thumb, full in
                MockImage(id: media.id.uuidString, thumbnail: thumb!, full: full!)
            }
    }

    func makeMockVideos() async -> [MockVideo] {
        await medias
            .filter { $0.type == .video }
            .asyncMap { (media : Media) -> (Media, URL?, URL?) in
                (media, await media.getThumbnailURL(), await media.getURL())
            }
            .filter { (media: Media, thumb: URL?, full: URL?) -> Bool in
                thumb != nil && full != nil
            }
            .map { media, thumb, full in
                MockVideo(id: media.id.uuidString, thumbnail: thumb!, full: full!)
            }
    }

    func toMockMessage(user: MockUser, status: Message.Status = .read) async -> MockMessage {
        MockMessage(
            uid: id ?? UUID().uuidString,
            sender: user,
            createdAt: createdAt,
            status: user.isCurrentUser ? status : nil,
            text: text,
            images: await makeMockImages(),
            videos: await makeMockVideos(),
            recording: recording,
            replyMessage: replyMessage
        )
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
