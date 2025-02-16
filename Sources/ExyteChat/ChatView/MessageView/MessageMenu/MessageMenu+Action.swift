//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI

public protocol MessageMenuAction: Equatable, CaseIterable {
    func title() -> String
    func icon() -> Image
}

public enum DefaultMessageMenuAction: MessageMenuAction {

    case copy
    case reply
    case edit(saveClosure: (String) -> Void)

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
            Image(systemName: "bubble.and.pencil")
        }
    }

    public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (.copy, .copy),
             (.reply, .reply),
             (.edit(_), .edit(_)):
            return true
        default:
            return false
        }
    }

    public static var allCases: [DefaultMessageMenuAction] = [
        .copy, .reply, .edit(saveClosure: {_ in})
    ]
}
