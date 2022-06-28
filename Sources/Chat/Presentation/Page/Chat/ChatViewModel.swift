//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

public typealias ChatPaginationClosure = (Message) -> Void

final class ChatViewModel: ObservableObject {
//    @Published var messages: [Message]
    @Published var fullscreenAttachmentItem: Optional<any Attachment> = nil

//    var paginationClosure: ChatPaginationClosure?

    private var subscriptions = Set<AnyCancellable>()

//    init(messages: [Message], paginationClosure: ChatPaginationClosure? = nil) {
//        self.messages = messages
//        self.paginationClosure = paginationClosure
//    }

//    func loadMoreContent(current: Message) {
//        guard paginationClosure != nil else {
//            return
//        }
//        let thresholdIndex = messages.index(messages.endIndex, offsetBy: -1)
//        if thresholdIndex == current.id {
//            paginationClosure?(current)
//        }
//    }
}
