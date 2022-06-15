//
//  Created by Alex.M on 15.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class AttachmentsViewModel: ObservableObject {
    let attachments: [Media]
    let sendMessageClosure: (Message) -> Void

    @Published var message = Message(id: 0)
    @Published var isShown = true

    private var subscriptions = Set<AnyCancellable>()

    init(attachments: [Media], message: String? = nil, onSend: @escaping (Message) -> Void) {
        self.attachments = attachments
        self.sendMessageClosure = onSend
        self.message.text = message ?? ""
    }

    func onTapSendMessage() {
        let allMediasPublisher = attachments
            .publisher
            .receive(on: DispatchQueue.global())
            .flatMap { media in
                media.getUrl()
                    .map { url in (media, url) }
            }
            .share()

        let imagesPublisher = allMediasPublisher
            .filter { $0.0.type == .image }
            .compactMap { $0.1 }
            .collect()
            .handleEvents(
                receiveOutput: { [weak self] in
                    self?.message.imagesURLs = $0
                }
            )
            .map { _ in }

        let videosPublisher = allMediasPublisher
            .filter { $0.0.type == .video }
            .compactMap { $0.1 }
            .collect()
            .handleEvents(
                receiveOutput: { [weak self] in
                    self?.message.videosURLs = $0
                }
            )
            .map { _ in }

        imagesPublisher
            .merge(with: videosPublisher)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard completion == .finished
                    else { fatalError("Publisher with Never faiture type shouldn't ever get error") }
                    self?.sendMessage()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)
    }
}

private extension AttachmentsViewModel {
    func sendMessage() {
        sendMessageClosure(message)
        message = Message(id: 0)
        isShown = false
    }
}
