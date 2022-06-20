//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class DraftMessageService: ObservableObject {
    var medias: CurrentValueSubject<[Media], Never> = CurrentValueSubject([])
    var text: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    var didSendMessage: ((DraftMessage) -> Void)?

    private(set) var attachments: [any Attachment] = []

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

    func sendMessage(text: String) -> AnyCancellable {
        self.text.value = text

        return mapAttachmentsForSend()
            .compactMap { [text] in
                DraftMessage(
                    text: text,
                    attachments: $0,
                    createdAt: Date()
                )
            }
            .sink { draft in
                DispatchQueue.main.async { [weak self, draft] in
                    self?.didSendMessage?(draft)
                    self?.reset()
                }
            }
    }

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.text.value = ""
            self?.medias.value = []
            self?.attachments = []
        }
    }

    func remove(media: Media) {
        DispatchQueue.main.async { [media, weak self] in
            self?.medias.value.removeAll { item in
                item.id == media.id
            }
        }
    }

    func select(medias: [Media]) {
        DispatchQueue.main.async { [medias, weak self] in
            self?.medias.value = medias
        }
    }
}
