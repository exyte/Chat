//
//  ChatLocalization.swift
//  Chat
//
//  Created by Aman Kumar on 18/12/24.
//

import Foundation

public struct ChatLocalization: Hashable {
    public var inputPlaceholder: String
    public var signatureText: String
    public var cancelButtonText: String
    public var recentToggleText: String
    public var waitingForNetwork: String
    public var recordingText: String
    public var replyToText: String

    public init(inputPlaceholder: String, signatureText: String, cancelButtonText: String, recentToggleText: String, waitingForNetwork: String, recordingText: String, replyToText: String) {
        self.inputPlaceholder = inputPlaceholder
        self.signatureText = signatureText
        self.cancelButtonText = cancelButtonText
        self.recentToggleText = recentToggleText
        self.waitingForNetwork = waitingForNetwork
        self.recordingText = recordingText
        self.replyToText = replyToText
    }
}

extension ChatLocalization {
    public static let defaultLocalization = ChatLocalization(
        inputPlaceholder: "Type a message...",
        signatureText: "Add signature...",
        cancelButtonText: "Cancel",
        recentToggleText: "Recents",
        waitingForNetwork: "Waiting for network",
        recordingText: "Recording...",
        replyToText: "Reply to"
    )
}
