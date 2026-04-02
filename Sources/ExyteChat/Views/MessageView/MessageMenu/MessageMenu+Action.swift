//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI

public protocol MessageMenuAction: Equatable, CaseIterable {
    func title() -> String
    func icon() -> Image
    
    static func menuItems(for message: Message, availableMessageMenuItems: [AvailableMesssageMenuType]) -> [Self]
}

extension MessageMenuAction {
    public static func menuItems(for message: Message, availableMessageMenuItems: [AvailableMesssageMenuType]) -> [Self] {
        Self.allCases.map { $0 }
    }
}

public enum DefaultMessageMenuAction: MessageMenuAction, Sendable {

    case copy
    case reply
    case edit(saveClosure: @Sendable (String) -> Void)

    public func title() -> String {
        switch self {
        case .copy:
            "Copy"
        case .reply:
            "Reply"
        case .edit:
            "Edit"
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
        }
    }

    nonisolated public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (.copy, .copy),
             (.reply, .reply),
             (.edit(_), .edit(_)):
            return true
        default:
            return false
        }
    }

    public static let allCases: [DefaultMessageMenuAction] = [
        .copy, .reply, .edit(saveClosure: {_ in})
    ]
    
    static public func menuItems(
        for message: Message, availableMessageMenuItems: [AvailableMesssageMenuType]
    ) -> [DefaultMessageMenuAction] {

        var menuItems: [DefaultMessageMenuAction] = []
        if message.user.isCurrentUser {
            if availableMessageMenuItems.contains(.copy) {
                menuItems.append(.copy)
            }
            if availableMessageMenuItems.contains(.reply) {
                menuItems.append(.reply)
            }
            if availableMessageMenuItems.contains(.edit) {
                menuItems.append(.edit(saveClosure: { _ in }))
            }
            return menuItems
        } else {
            if availableMessageMenuItems.contains(.copy) {
                menuItems.append(.copy)
            }
            if availableMessageMenuItems.contains(.reply) {
                menuItems.append(.reply)
            }
            return menuItems
        }
    }
}
