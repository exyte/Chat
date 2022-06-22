//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class DraftComposeState {
    var medias: CurrentValueSubject<[Media], Never> = CurrentValueSubject([])
    var text: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    var didSendMessage: ((DraftMessage) -> Void)?

    func mapAttachmentsForSend() -> AnyPublisher<[any Attachment], Never> {
        medias.value
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
            .eraseToAnyPublisher()
    }

    func update(text: String) {
        DispatchQueue.main.async { [weak self, text] in
            self?.text.value = text
        }
    }

    func sendMessage(text: String) -> AnyPublisher<Void, Never> {
        self.text.value = text

        return mapAttachmentsForSend()
            .compactMap { [text] in
                DraftMessage(
                    text: text,
                    attachments: $0,
                    createdAt: Date()
                )
            }
            .handleEvents(receiveOutput: { draft in
                DispatchQueue.main.async { [weak self, draft] in
                    self?.didSendMessage?(draft)
                    self?.reset()
                }
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.text.value = ""
            self?.medias.value = []
        }
    }

    func select(medias: [Media]) {
        DispatchQueue.main.async { [medias, weak self] in
            self?.medias.value = medias
        }
    }
}
