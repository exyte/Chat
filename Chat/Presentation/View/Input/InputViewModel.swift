//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class InputViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var medias: [Media] = []
    @Published var showPicker = false

    @Published var isAvailableSend = false

    var didSendMessage: ((DraftMessage) -> Void)?

    private var subscriptions = Set<AnyCancellable>()

    init() {}

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.text = ""
            self?.medias = []
            self?.showPicker = false
        }
    }

    func send() {
        sendMessage()
            .store(in: &subscriptions)
    }

    func validateDraft() {
        let notEmptyTextInChatWindow = !text.isEmpty && !showPicker
        let notEmptyMediasInPickerWindow = !medias.isEmpty && showPicker
        isAvailableSend = notEmptyTextInChatWindow || notEmptyMediasInPickerWindow
    }
}

private extension InputViewModel {
    
    func mapAttachmentsForSend() -> AnyPublisher<[any Attachment], Never> {
        medias.publisher
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

    func sendMessage() -> AnyCancellable {
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
}
