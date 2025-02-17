//
//  ChatView+SwipeActions.swift
//  Chat
//

import SwiftUI

public extension ChatView {
    /// Adds Swipe Actions to Messages within your ChatView
    /// - Parameters:
    ///   - edge: Either the leading or trailing edge of the Message
    ///   - allowsFullSwipe: If true, a full swipe will trigger the first `SwipeAction` provided in the `items` list
    ///   - items: A list of `SwipeAction`s to include
    /// - Returns: The modified `ChatView`
    ///
    /// **Example**
    /// ``` swift
    /// // Example: Adding Swipe Actions to your ChatView
    /// ChatView( ... )
    /// .swipeActions(edge: .leading, allowsFullSwipe: false, items: [
    ///     // SwipeActions are similar to Buttons, they accept an Action and a ViewBuilder
    ///     SwipeAction(action: onDelete, activeFor: { $0.user.isCurrentUser }, background: .red) {
    ///         swipeActionButtonStandard(title: "Delete", image: "xmark.bin")
    ///     },
    ///     // Set the background color of a SwipeAction in the initializer,
    ///     // instead of trying to apply a background color in your ViewBuilder
    ///     SwipeAction(action: onReply, background: .blue) {
    ///         swipeActionButtonStandard(title: "Reply", image: "arrowshape.turn.up.left")
    ///     },
    ///     // SwipeActions can also be selectively shown based on the message,
    ///     // here we only show the Edit action when the message is from the current sender
    ///     // (cause you can't just go around editing other peoples messages...)
    ///     SwipeAction(action: onEdit, activeFor: { $0.user.isCurrentUser }, background: .gray) {
    ///         swipeActionButtonStandard(title: "Edit", image: "bubble.and.pencil")
    ///     }
    /// ])
    /// // Just like with UITableView's we can enable, or disable, `allowsFullSwipe` triggering the first action
    /// // In this example a full swipe will automatically trigger the `onInfo` callback
    /// .swipeActions(edge: .trailing, allowsFullSwipe: true, items: [
    ///     // SwipeAction's accept almost any static content (no animations), so play around and style your buttons!
    ///     // - Note: leaving the background parameter empty here defaults to the ChatView's mainBG color (providing a 'transparent' background look)
    ///     SwipeAction(action: onInfo) {
    ///         // This is an example of a swipe button with a gradient foregroundStyle
    ///         Image(systemName: "info.bubble")
    ///             .imageScale(.large)
    ///             .foregroundStyle(.blue.gradient)
    ///             .frame(height: 30)
    ///         Text("Info")
    ///             .foregroundStyle(.blue.gradient)
    ///             .font(.footnote)
    ///     }
    /// ])
    /// ```
    func swipeActions<V:View>(edge: HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, items: [SwipeAction<V>]) -> ChatView {
        var view = self
        switch edge {
        case .leading:
            view.listSwipeActions = .init(
                leading: .init(allowsFullSwipe: allowsFullSwipe, actions: items),
                trailing: view.listSwipeActions.trailing
            )
        case .trailing:
            view.listSwipeActions = .init(
                leading: view.listSwipeActions.leading,
                trailing: .init(allowsFullSwipe: allowsFullSwipe, actions: items)
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
    let allowsFullSwipe: Bool
    let actions: [SwipeActionable]
}

/// A ChatView list swipe action Button
///
/// **Example**
/// ```swift
/// // SwipeActions are similar to Buttons, they accept an Action and a ViewBuilder
/// SwipeAction(action: { msg, _ in print("Info requested for \(msg)") }, activeFor: { $0.user.isCurrentUser }, background: .gray) {
///    // This is an example of a swipe button with a gradient foregroundStyle
///    Image(systemName: "info.bubble")
///        .imageScale(.large)
///        .foregroundStyle(.blue.gradient)
///        .frame(height: 30)
///    Text("Info")
///        .foregroundStyle(.blue.gradient)
///        .font(.footnote)
/// }
/// ```
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
