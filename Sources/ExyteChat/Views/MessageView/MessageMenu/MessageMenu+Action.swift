//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI

public protocol MessageMenuAction: Equatable, CaseIterable {
    func title() -> String
    func icon() -> Image
    
    static func menuItems(for message: Message) -> [Self]
}

extension MessageMenuAction {
    public static func menuItems(for message: Message) -> [Self] {
        Self.allCases.map { $0 }
    }
}

public enum DefaultMessageMenuAction: MessageMenuAction, Sendable {

    case copy
    case reply
    case edit(saveClosure: @Sendable (String) -> Void)
    case delete

    public func title() -> String {
        switch self {
        case .copy:
            "Copy"
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        case .delete:
            "Delete"
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
        case .delete:
            Image(systemName: "trash")
        }
    }

    nonisolated public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (.copy, .copy),
             (.reply, .reply),
             (.edit(_), .edit(_)),
             (.delete, .delete):
            return true
        default:
            return false
        }
    }

    public static let allCases: [DefaultMessageMenuAction] = [
        .copy, .reply, .edit(saveClosure: {_ in}), .delete,
    ]
    
    static public func menuItems(for message: Message) -> [DefaultMessageMenuAction] {
        if message.user.isCurrentUser {
            return allCases
        } else {
            return [.copy, .reply, .delete]
        }
    }
}
