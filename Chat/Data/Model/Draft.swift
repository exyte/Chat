//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import AssetsPicker

struct DraftMessage {
    let text: String
    let attachments: [any Attachment]
    let createAt: Date
}

final class DraftViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var attachments: [Media] = []
    @Published var isShownAttachments = false

    var didSendMessage: ((DraftMessage) -> Void)?
    var processed: [any Attachment] = []

    init(text: String = "", attachments: [Media] = [], isShownAttachments: Bool = false) {
        self.text = text
        self.attachments = attachments
        self.isShownAttachments = isShownAttachments
    }

    func reset() {
        text = ""
        attachments = []
        isShownAttachments = false
    }

    func remove(attachment: Media) {
        attachments.removeAll { item in
            item.id == attachment.id
        }
        isShownAttachments = !attachments.isEmpty
    }

    func send() {
        let draft = DraftMessage(
            text: text,
            attachments: processed,
            createAt: Date()
        )
        didSendMessage?(draft)
        reset()
    }

    func onSelect(medias: [Media]) {
        guard !medias.isEmpty else {
            return
        }
        self.attachments = medias
        self.isShownAttachments = true
    }
}
