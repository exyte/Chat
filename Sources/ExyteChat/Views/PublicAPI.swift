//
//  PublicAPI.swift
//  Chat
//
//  Created by Alisa Mylnikova on 12.02.2026.
//

import SwiftUI
import ExyteMediaPicker

public extension ChatView {

    // MARK: - Simple view builders
    // please use init to pass message builders, etc.

    func mainHeaderBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.mainHeaderBuilder = {
            AnyView(builder())
        }
        return view
    }

    func headerBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.headerBuilder = { date in
            AnyView(builder(date))
        }
        return view
    }

    func betweenListAndInputViewBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.betweenListAndInputViewBuilder = {
            AnyView(builder())
        }
        return view
    }

    // MARK: - Customizations

    func isListAboveInputView(_ isAbove: Bool) -> ChatView {
        var view = self
        view.isListAboveInputView = isAbove
        return view
    }

    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.showNetworkConnectionProblem = show
        return view
    }

    func contentInsets(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> ChatView {
        var view = self
        // NOTE: top and bottom are vice versa - because chat is an upside down UITableView
        view.contentInsets = UIEdgeInsets(top: bottom, left: left, bottom: top, right: right)
        return view
    }

    func showDateHeaders(_ showDateHeaders: Bool) -> ChatView {
        var view = self
        view.showDateHeaders = showDateHeaders
        return view
    }

    func isScrollEnabled(_ isScrollEnabled: Bool) -> ChatView {
        var view = self
        view.isScrollEnabled = isScrollEnabled
        return view
    }

    /// Sets the keyboard dismiss mode for the chat list
    /// - Parameter mode: The keyboard dismiss mode (.interactive, .onDrag, or .none)
    /// - Default is .none
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> ChatView {
        var view = self
        view.keyboardDismissMode = mode
        return view
    }

    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.showMessageMenuOnLongPress = show
        return view
    }

    /// Sets the general duration of various message menu animations
    ///
    /// This value is more akin to 'how snappy' the message menu feels
    /// - Note: Good values are between 0.15 - 0.5 (defaults to 0.3)
    /// - Important: This value is clamped between 0.1 and 1.0
    func messageMenuAnimationDuration(_ duration: Double) -> ChatView {
        var view = self
        view.messageMenuAnimationDuration = max(0.1, min(1.0, duration))
        return view
    }

    /// when user scrolls up to `pageSize`-th meassage, call the handler function, so user can load more messages
    /// NOTE: doesn't work well with `isScrollEnabled` false
    func enableLoadMore(pageSize: Int, _ handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view.paginationHandler = PaginationHandler(handleClosure: handler, pageSize: pageSize)
        return view
    }

    func localization(_ localization: ChatLocalization) -> ChatView {
        var view = self
        view.localization = localization
        return view
    }

    /// Sets a delegate for handling and configuring message reactions
    func messageReactionDelegate(_ reactionDelegate: ReactionDelegate) -> ChatView {
        var view = self
        view.reactionDelegate = reactionDelegate
        return view
    }

    /// Constructs, and applies, a ReactionDelegate for you based on the provided closures
    func onMessageReaction(
        didReactTo: @escaping (Message, DraftReaction) -> Void,
        canReactTo: ((Message) -> Bool)? = nil,
        availableReactionsFor: ((Message) -> [ReactionType]?)? = nil,
        allowEmojiSearchFor: ((Message) -> Bool)? = nil,
        shouldShowOverviewFor: ((Message) -> Bool)? = nil
    ) -> ChatView {
        var view = self
        view.reactionDelegate = DefaultReactionConfiguration(
            didReact: didReactTo,
            canReact: canReactTo,
            reactions: availableReactionsFor,
            allowEmojiSearch: allowEmojiSearchFor,
            shouldShowOverview: shouldShowOverviewFor
        )
        return view
    }

    func swipeActions<V: View>(edge: HorizontalEdge = .trailing, performsFirstActionWithFullSwipe: Bool = true, items: [SwipeAction<V>]) -> ChatView {
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

    // MARK: - Built-in message view

    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }

    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.tapAvatarClosure = closure
        return view
    }

    func showMessageTimeView(_ isShow: Bool) -> ChatView {
        var view = self
        view.showMessageTimeView = isShow
        return view
    }

    func messageLinkPreviewLimit(_ limit: Int) -> ChatView {
        var view = self
        view.messageLinkPreviewLimit = limit
        return view
    }

    func linkPreviewsEnabled(_ enabled: Bool) -> ChatView {
        messageLinkPreviewLimit(enabled ? self.messageLinkPreviewLimit : 0)
    }

    func shouldShowPreviewForLink(_ shouldShowPreviewForLink: @escaping (URL) -> Bool) -> ChatView {
        var view = self
        view.shouldShowPreviewForLink = shouldShowPreviewForLink
        return view
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageFont = font
        return view
    }

    func messageUseMarkdown(_ messageUseMarkdown: Bool) -> ChatView {
        messageUseStyler(String.markdownStyler)
    }

    func messageUseStyler(_ styler: @escaping (String) -> AttributedString) -> ChatView {
        var view = self
        view.messageStyler = styler
        return view
    }

    // MARK: - Built-in input view

    func setAvailableInputs(_ types: [AvailableInputType]) -> ChatView {
        var view = self
        view.availableInputs = types
        return view
    }

    func setRecorderSettings(_ settings: RecorderSettings) -> ChatView {
        var view = self
        view.recorderSettings = settings
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = MediaPickerSelectionParameters()
        view.mediaPickerSelectionParameters?.selectionLimit = assetsPickerLimit
        return view
    }

    func setMediaPickerSelectionParameters(_ params: MediaPickerSelectionParameters) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = params
        return view
    }

    func setMediaPickerParameters(_ params: MediaPickerParameters) -> ChatView {
        var view = self
        view.mediaPickerParameters = params
        return view
    }

    func orientationHandler(orientationHandler: @escaping MediaPickerOrientationHandler) -> ChatView {
        var view = self
        view.orientationHandler = orientationHandler
        return view
    }
}
