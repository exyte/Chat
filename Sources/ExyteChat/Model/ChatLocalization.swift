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
    public var shareLiveLocationText: String
    public var stopSharingLocationText: String
    public var liveLocationText: String
    public var liveLocationEndedText: String
    public var liveLocationUpdatedJustNowText: String
    /// Format string with a single `%d` placeholder for the number of minutes, e.g. "updated %d min ago"
    public var liveLocationUpdatedMinutesAgoFormat: String
    public var openInMapsText: String

    public init(
        inputPlaceholder: String,
        signatureText: String,
        cancelButtonText: String,
        recentToggleText: String,
        waitingForNetwork: String,
        recordingText: String,
        replyToText: String,
        attachMediaText: String = String(localized: "Media"),
        attachGifText: String = String(localized: "GIF"),
        attachCameraText: String = String(localized: "Camera"),
        attachDocumentText: String = String(localized: "Document"),
        attachLocationText: String = String(localized: "Location"),
        sendLocationText: String = String(localized: "Send this location"),
        shareLiveLocationText: String = String(localized: "Share Live Location"),
        stopSharingLocationText: String = String(localized: "Stop Sharing"),
        liveLocationText: String = String(localized: "Live Location"),
        liveLocationEndedText: String = String(localized: "Live location ended"),
        liveLocationUpdatedJustNowText: String = String(localized: "updated just now"),
        liveLocationUpdatedMinutesAgoFormat: String = String(localized: "updated %d min ago"),
        openInMapsText: String = String(localized: "Open in Maps")
    ) {
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
        self.shareLiveLocationText = shareLiveLocationText
        self.stopSharingLocationText = stopSharingLocationText
        self.liveLocationText = liveLocationText
        self.liveLocationEndedText = liveLocationEndedText
        self.liveLocationUpdatedJustNowText = liveLocationUpdatedJustNowText
        self.liveLocationUpdatedMinutesAgoFormat = liveLocationUpdatedMinutesAgoFormat
        self.openInMapsText = openInMapsText
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
            sendLocationText: String(localized: "Send this location"),
            shareLiveLocationText: String(localized: "Share Live Location"),
            stopSharingLocationText: String(localized: "Stop Sharing"),
            liveLocationText: String(localized: "Live Location"),
            liveLocationEndedText: String(localized: "Live location ended"),
            liveLocationUpdatedJustNowText: String(localized: "updated just now"),
            liveLocationUpdatedMinutesAgoFormat: String(localized: "updated %d min ago"),
            openInMapsText: String(localized: "Open in Maps")
        )
    }
}
