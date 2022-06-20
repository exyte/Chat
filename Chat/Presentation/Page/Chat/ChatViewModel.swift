//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    let draftMessageService: DraftMessageService

    @Published var showMedias: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    init(draftMessageService: DraftMessageService = DraftMessageService()) {
        self.draftMessageService = draftMessageService

        draftMessageService.medias
            .map { !$0.isEmpty }
            .assign(to: &$showMedias)
    }
}
