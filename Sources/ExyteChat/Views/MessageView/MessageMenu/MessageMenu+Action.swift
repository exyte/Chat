//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI

public protocol MessageMenuAction: Equatable, CaseIterable {
    func title() -> String
    func icon() -> Image
    func isDestructive() -> Bool

    static func menuItems(for message: Message) -> [Self]
}

extension MessageMenuAction {
    public func isDestructive() -> Bool { false }

    public static func menuItems(for message: Message) -> [Self] {
        Self.allCases.map { $0 }
    }
}

public enum DefaultMessageMenuAction: MessageMenuAction, Sendable {

    case copy
    case reply
    case edit(saveClosure: @Sendable (String) -> Void)
    case share

    public init() {self.init()}

    public func title() -> String {
        switch self {
        case .copy:
            "Copy"
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        case .share:
            "Share"
        }
    }

    public func icon() -> Image {
        switch self {
        case .copy:
            Image(systemName: "doc.on.doc")
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            if #available(iOS 18.0, macCatalyst 18.0, *) {
                Image(systemName: "bubble.and.pencil")
            } else {
                Image(systemName: "square.and.pencil")
            }
        case .share:
            Image(systemName: "square.and.arrow.up")
        }
    }

    nonisolated public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (.copy, .copy),
             (.reply, .reply),
             (.edit(_), .edit(_)),
             (.share, .share):
            return true
        default:
            return false
        }
    }

    public static let allCases: [DefaultMessageMenuAction] = [
        .copy, .reply, .edit(saveClosure: {_ in}), .share
    ]

    static public func menuItems(for message: Message) -> [DefaultMessageMenuAction] {
        var items: [DefaultMessageMenuAction] = message.user.isCurrentUser ? [.copy, .reply, .edit(saveClosure: {_ in})] : [.copy, .reply]
        let hasShareableAttachments = message.attachments.contains { $0.fullUploadStatus == nil || $0.fullUploadStatus == .complete }
        if hasShareableAttachments {
            items.append(.share)
        }
        return items
    }
}
