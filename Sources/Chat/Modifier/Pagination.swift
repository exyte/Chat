//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import SwiftUI

final class PaginationState: ObservableObject {
    let onEvent: ChatPaginationClosure?
    let offset: Int

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

struct PaginationStateKey: EnvironmentKey {
    static var defaultValue: PaginationState = PaginationState()
}

extension EnvironmentValues {
    var chatPagination: PaginationState {
        get { self[PaginationStateKey.self] }
        set { self[PaginationStateKey.self] = newValue }
    }
}

public extension View {
    func chatEnablePagination(offset: Int = 0, handler: @escaping ChatPaginationClosure) -> some View {
        self.environment(\.chatPagination, PaginationState(onEvent: handler, offset: offset))
    }
}
