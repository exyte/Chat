//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

public typealias ChatPaginationClosure = (Message) -> Void

final class ChatViewModel: ObservableObject {
    
    @Published private(set) var fullscreenAttachmentItem: Optional<Attachment> = nil
    @Published var fullscreenAttachmentPresented = false

    @Published var messageMenuRow: MessageRow?

    public var didSendMessage: (DraftMessage) -> Void = {_ in}
    
    func presentAttachmentFullScreen(_ attachment: Attachment) {
        fullscreenAttachmentItem = attachment
        fullscreenAttachmentPresented = true
    }
    
    func dismissAttachmentFullScreen() {
        fullscreenAttachmentPresented = false
        fullscreenAttachmentItem = nil
    }

    func sendMessage(_ message: DraftMessage) {
        didSendMessage(message)
    }
}
