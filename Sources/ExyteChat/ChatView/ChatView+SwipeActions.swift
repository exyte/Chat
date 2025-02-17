//
//  ChatView+SwipeActions.swift
//  Chat
//

import SwiftUI

public extension ChatView {
    func swipeActions<V:View>(edge: HorizontalEdge = .trailing, performsFirstActionWithFullSwipe: Bool = true, items: [SwipeAction<V>]) -> ChatView {
        var view = self
        switch edge {
        case .leading:
            view.listSwipeActions = .init(
                leading: .init(performsFirstActionWithFullSwipe: performsFirstActionWithFullSwipe, actions: items),
                trailing: view.listSwipeActions.trailing
            )
        case .trailing:
            view.listSwipeActions = .init(
                leading: view.listSwipeActions.leading,
                trailing: .init(performsFirstActionWithFullSwipe: performsFirstActionWithFullSwipe, actions: items)
            )
        }
        return view
    }
}

protocol SwipeActionable {
    func render(type: ChatType) -> UIImage
    var action: (Message, @escaping (Message, DefaultMessageMenuAction) -> Void) -> Void { get }
    var activeFor: (Message) -> Bool { get }
    var background: Color? { get }
}

/// A simple container for both the leading and trailing swipe actions
struct ListSwipeActions {
    let leading: ListSwipeAction?
    let trailing: ListSwipeAction?
    
    init(leading: ListSwipeAction? = nil, trailing: ListSwipeAction? = nil) {
        self.leading = leading
        self.trailing = trailing
    }
}

/// A container for either leading or trailing swipe actions and wether they support fullSwipe actions
struct ListSwipeAction {
    let performsFirstActionWithFullSwipe: Bool
    let actions: [SwipeActionable]
}

public struct SwipeAction<V: View>: @preconcurrency SwipeActionable {
    let action: (Message, @escaping (Message, DefaultMessageMenuAction) -> Void) -> Void
    let activeFor: (Message) -> Bool
    let content: () -> V
    let background: Color?
    
    public init(@ViewBuilder content: @escaping () -> V, background: Color? = nil, activeFor: @escaping (Message) -> Bool = { _ in true}, action: @escaping (Message, @escaping (Message, DefaultMessageMenuAction) -> Void) -> Void) {
        self.content = content
        self.action = action
        self.activeFor = activeFor
        self.background = background
    }
    
    public init(action: @escaping (Message, @escaping (Message, DefaultMessageMenuAction) -> Void) -> Void, activeFor: @escaping (Message) -> Bool = { _ in true}, background: Color? = nil, @ViewBuilder content: @escaping () -> V) {
        self.content = content
        self.action = action
        self.activeFor = activeFor
        self.background = background
    }
    
    @MainActor
    func render(type: ChatType) -> UIImage {
        let renderer = ImageRenderer(content: self.content().rotationEffect(type == .conversation ? .degrees(180) : .degrees(0)))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage!
    }
}
