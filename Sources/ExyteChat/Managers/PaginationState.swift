//
//  Created by Alex.M on 30.06.2022.
//

import Foundation

public typealias ChatPaginationClosure = @Sendable (Message) async -> Void

final actor PaginationHandler: ObservableObject {
    let handleClosure: ChatPaginationClosure

    init(handleClosure: @escaping ChatPaginationClosure) {
        self.handleClosure = handleClosure
    }
}
