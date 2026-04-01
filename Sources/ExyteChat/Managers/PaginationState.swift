//
//  Created by Alex.M on 30.06.2022.
//

import Foundation

struct PaginationHandler {
    /// this mean that when (messages.count - 1 - offset)-th message is displayed handleClosure will be called
    /// 0 means last message triggers handleClosure
    let offset: Int
    let handleClosure: ()->()

    init(offset: Int = 0, handleClosure: @escaping ()->()) {
        self.offset = offset
        self.handleClosure = handleClosure
    }
}
