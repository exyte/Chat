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

    func handle(_ message: Message, ids: [String]) {
        guard shouldHandlePagination else {
            return
        }
        if ids.prefix(offset + 1).contains(message.id) {
            onEvent?(message)
        }
    }
}
