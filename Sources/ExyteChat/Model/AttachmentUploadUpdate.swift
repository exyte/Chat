import SwiftUI

public struct AttachmentUploadUpdate {
  
  public enum UpdateAction: Codable, Hashable {
      case cancel
  }
  
  public let messageId: String
  public let attachmentId: String
  public let updateAction: UpdateAction
  
  public init(
    messageId: String,
    attachmentId: String,
    updateAction: UpdateAction
  ) {
    self.messageId = messageId
    self.attachmentId = attachmentId
    self.updateAction = updateAction
  }
}
