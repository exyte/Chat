//
//  Created by Alex.M on 15.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class AttachmentsViewModel: ObservableObject {
    let draftMessageService: DraftComposeState

    @Published var text: String = ""
    @Published var medias: [Media] = []

    private var subscriptions = Set<AnyCancellable>()

    init(draftMessageService: DraftComposeState) {
        self.draftMessageService = draftMessageService

        self.text = draftMessageService.text.value

        draftMessageService.medias.assign(to: &$medias)
    }

    func onTapSendMessage() {
        draftMessageService
            .sendMessage(text: text)
            .store(in: &subscriptions)
    }

    func updateText() {
        draftMessageService.update(text: text)
    }

    func cancel() {
        draftMessageService.reset()
    }

    func delete(_ media: Media) {
        draftMessageService.update(text: text)
        draftMessageService.remove(media: media)
    }
}
