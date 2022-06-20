//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import AssetsPicker

final class InputViewModel: ObservableObject {
    let draftMessageService: DraftMessageService

    @Published var text: String = ""
    @Published var showMedias: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    init(draftMessageService: DraftMessageService) {
        self.draftMessageService = draftMessageService

        self.text = draftMessageService.text.value

        draftMessageService.medias
            .map { !$0.isEmpty }
            .assign(to: &$showMedias)
    }

    func reset() {
        draftMessageService.reset()
    }

    func remove(attachment: Media) {
        draftMessageService.remove(media: attachment)
    }

    func send() {
        draftMessageService
            .sendMessage(text: text)
            .store(in: &subscriptions)
    }

    func updateText() {
        draftMessageService.update(text: text)
    }

    func onSelect(medias: [Media]) {
        draftMessageService.select(medias: medias)
    }
}
