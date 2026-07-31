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
    public var attachMediaText: String
    public var attachGifText: String
    public var attachCameraText: String
    public var attachDocumentText: String
    public var attachLocationText: String
    public var sendLocationText: String

    public init(inputPlaceholder: String, signatureText: String, cancelButtonText: String, recentToggleText: String, waitingForNetwork: String, recordingText: String, replyToText: String, attachMediaText: String = String(localized: "Media"), attachGifText: String = String(localized: "GIF"), attachCameraText: String = String(localized: "Camera"), attachDocumentText: String = String(localized: "Document"), attachLocationText: String = String(localized: "Location"), sendLocationText: String = String(localized: "Send this location")) {
        self.inputPlaceholder = inputPlaceholder
        self.signatureText = signatureText
        self.cancelButtonText = cancelButtonText
        self.recentToggleText = recentToggleText
        self.waitingForNetwork = waitingForNetwork
        self.recordingText = recordingText
        self.replyToText = replyToText
        self.attachMediaText = attachMediaText
        self.attachGifText = attachGifText
        self.attachCameraText = attachCameraText
        self.attachDocumentText = attachDocumentText
        self.attachLocationText = attachLocationText
        self.sendLocationText = sendLocationText
    }

   public static var defaultLocalization: ChatLocalization {
        ChatLocalization(
            inputPlaceholder: String(localized: "Type a message..."),
            signatureText: String(localized: "Add signature..."),
            cancelButtonText: String(localized: "Cancel"),
            recentToggleText: String(localized: "Recents"),
            waitingForNetwork: String(localized: "Waiting for network"),
            recordingText: String(localized: "Recording..."),
            replyToText: String(localized: "Reply to"),
            attachMediaText: String(localized: "Media"),
            attachGifText: String(localized: "GIF"),
            attachCameraText: String(localized: "Camera"),
            attachDocumentText: String(localized: "Document"),
            attachLocationText: String(localized: "Location"),
            sendLocationText: String(localized: "Send this location")
        )
    }
}
