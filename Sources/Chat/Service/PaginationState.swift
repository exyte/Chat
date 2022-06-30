//
//  Created by Alex.M on 30.06.2022.
//

import Foundation

final class PaginationState: ObservableObject {
    var onEvent: ChatPaginationClosure?
    var offset: Int

    var shouldHandlePagination: Bool {
        onEvent != nil
    }

    init(onEvent: ChatPaginationClosure? = nil, offset: Int = 0) {
        self.onEvent = onEvent
        self.offset = offset
    }

    func handle(_ message: Message, in messages: [Message]) {
        guard shouldHandlePagination else {
            return
        }
        let ids = messages
            .prefix(upTo: offset + 1)
            .map { $0.id }

        if ids.contains(message.id) {
            onEvent?(message)
        }
    }
}
