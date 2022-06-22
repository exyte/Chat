//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    let attachmentsFullscreenState = AttachmentsFullscreenState()

    @Published var showAttachmentsView: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    init() {
        attachmentsFullscreenState
            .showFullscreen
            .map { $0 != nil }
            .assign(to: &$showAttachmentsView)
    }
}
