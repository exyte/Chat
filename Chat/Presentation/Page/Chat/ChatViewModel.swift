//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    let draftMessageService: DraftComposeState
    let attachmentsFullscreenState = AttachmentsFullscreenState()

    @Published var showMedias: Bool = false
    @Published var showAttachmentsView: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    init(draftMessageService: DraftComposeState = DraftComposeState()) {
        self.draftMessageService = draftMessageService

        draftMessageService.medias
            .map { !$0.isEmpty }
            .assign(to: &$showMedias)

        attachmentsFullscreenState
            .showFullscreen
            .map { $0 != nil }
            .assign(to: &$showAttachmentsView)
    }
}
