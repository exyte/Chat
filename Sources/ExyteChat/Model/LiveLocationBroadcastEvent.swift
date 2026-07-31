//
//  LiveLocationBroadcastEvent.swift
//  Chat
//

import Foundation

/// Reports what's happening with the live location share currently being broadcast *from this device*.
///
/// Only one share can be active at a time: sending a new live-location message automatically ends whichever
/// one was already broadcasting (you'll get its `.ended` before the new share's first `.updated`) - the same
/// way Telegram only lets you broadcast one live location at once.
///
/// ExyteChat has no networking layer of its own (same as for regular messages) - the on-device location
/// tracking (`CLLocationManager`) is entirely internal, you never touch it. This event is only how you find
/// out about it, so you can mirror the change into your own message store/backend and propagate it to other
/// participants however your app does that.
public enum LiveLocationBroadcastEvent: Sendable {
    /// A fresh coordinate fix for the message with this id.
    case updated(messageId: String, liveLocation: LiveLocation)
    /// The share for the message with this id ended - its duration elapsed, the user tapped Stop Sharing,
    /// or it was superseded by a newer live share.
    case ended(messageId: String)
}
