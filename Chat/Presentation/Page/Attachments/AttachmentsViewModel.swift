//
//  Created by Alex.M on 15.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class AttachmentsViewModel: ObservableObject {
    var draftViewModel: DraftViewModel
    @Published var isShown = true

    private var subscriptions = Set<AnyCancellable>()

    init(draftViewModel: DraftViewModel) {
        self.draftViewModel = draftViewModel
    }

    func onTapSendMessage() {
        draftViewModel.attachments
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
                    self?.draftViewModel.processed = $0
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

    func cancel() {
        draftViewModel.reset()
    }

    func delete(_ media: Media) {
        draftViewModel.remove(attachment: media)
    }
}

private extension AttachmentsViewModel {
    func sendMessage() {
        draftViewModel.send()
        isShown = false
    }
}
