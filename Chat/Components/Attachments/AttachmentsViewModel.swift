//
//  Created by Alex.M on 15.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class AttachmentsViewModel: ObservableObject {
    @Published var attachments: [Media]
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
        attachments
            .publisher
            .receive(on: DispatchQueue.global())
            .flatMap { media in
                media.getUrl()
                    .map { url in (media, url) }
            }
            .compactMap { (media, url) -> (Media, URL)? in
                guard let url = url else { return nil }
                return (media, url)
            }
            .map { (media, url) -> any Attachment in
                switch media.type {
                case .image:
                    return ImageAttachment(url: url)
                case .video:
                    return VideoAttachment(url: url)
                }
            }
            .collect()
            .handleEvents(
                receiveOutput: { [weak self] in
                    self?.message.attachments = $0
                },
                receiveCompletion: { [weak self] completion in
                    guard completion == .finished
                    else { fatalError("Publisher with Never faiture type shouldn't ever get error") }

                    self?.sendMessage()
                }
            )
            .sink { _ in }
            .store(in: &subscriptions)
    }

    func delete(_ media: Media) {
        attachments.removeAll { item in
            item.id == media.id
        }
        if attachments.isEmpty {
            isShown = false
        }
    }
}

private extension AttachmentsViewModel {
    func sendMessage() {
        sendMessageClosure(message)
        message = Message(id: 0)
        isShown = false
    }
}
