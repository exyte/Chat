//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import UIKit
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {

    @Published private(set) var fullscreenAttachmentItem: Optional<Attachment> = nil
    @Published var fullscreenAttachmentPresented = false

    @Published var shareAttachmentsItem: ShareAttachmentsItem? = nil
    @Published private(set) var isPreparingAttachmentsShare = false

    @Published var messageMenuRow: MessageRow?
    
    /// The messages frame that is currently being rendered in the Message Menu
    /// - Note: Used to further refine a messages frame (instead of using the cell boundary), mainly used for positioning reactions
    @Published var messageFrame: CGRect = .zero
    
    /// Provides a mechanism to issue haptic feedback to the user
    /// - Note: Used when launching the MessageMenu
    
    let inputFieldId = UUID()
    let messageRecordingPlayer = RecordingPlayer()

    var didSendMessage: (DraftMessage) -> Void = {_ in }
    var didUpdateAttachmentStatus: (AttachmentUploadUpdate) -> Void = { _ in }
    var inputViewModel: InputViewModel?
    var globalFocusState: GlobalFocusState?

    func presentAttachmentFullScreen(_ attachment: Attachment) {
        fullscreenAttachmentItem = attachment
        fullscreenAttachmentPresented = true
    }
    
    func dismissAttachmentFullScreen() {
        fullscreenAttachmentPresented = false
        fullscreenAttachmentItem = nil
    }

    func shareAttachments(_ attachments: [Attachment]) {
        guard !attachments.isEmpty, !isPreparingAttachmentsShare else { return }
        isPreparingAttachmentsShare = true
        Task { [weak self] in
            let urls = await AttachmentSharing.prepareForSharing(attachments)
            guard let self else { return }
            self.isPreparingAttachmentsShare = false
            if !urls.isEmpty {
                self.shareAttachmentsItem = ShareAttachmentsItem(urls: urls)
            }
        }
    }
    
    func updateAttachmentStatus(_ uploadUpdate: AttachmentUploadUpdate) {
        didUpdateAttachmentStatus(uploadUpdate)
    }

    func sendMessage(_ message: DraftMessage) {
        didSendMessage(message)
    }

    func messageMenuAction() -> (Message, DefaultMessageMenuAction) -> Void {
        { [weak self] message, action in
            self?.messageMenuActionInternal(message: message, action: action)
        }
    }

    func focusTheInputTextView() {
        globalFocusState?.focus = .uuid(inputFieldId)
    }

    func messageMenuActionInternal(message: Message, action: DefaultMessageMenuAction) {
        switch action {
        case .copy:
            UIPasteboard.general.string = String(message.attributedText.characters)
        case .reply:
            withAnimation(.easeInOut(duration: 0.2)) {
                inputViewModel?.attachments.replyMessage = message.toReplyMessage()
            }
            focusTheInputTextView()
        case .edit(let saveClosure):
            inputViewModel?.text = String(message.attributedText.characters)
            inputViewModel?.edit(saveClosure)
            focusTheInputTextView()
        case .share:
            let shareableAttachments = message.attachments.filter { $0.fullUploadStatus == nil || $0.fullUploadStatus == .complete }
            shareAttachments(shareableAttachments)
        }
    }
}

struct ShareAttachmentsItem: Identifiable {
    let id = UUID()
    let urls: [URL]
}
