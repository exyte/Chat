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

    func dateHeaderBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.dateHeaderBuilder = { date in
            AnyView(builder(date))
        }
        return view
    }

    @available(*, deprecated, message: "use dateHeaderBuilder instead")
    func headerBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.dateHeaderBuilder = { date in
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
        view.chatCustomizationParameters.isListAboveInputView = isAbove
        return view
    }

    func showScrollToBottomButton(_ show: Bool) -> ChatView {
        var view = self
        view.chatCustomizationParameters.showScrollToBottomButton = show
        return view
    }

    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.chatCustomizationParameters.showNetworkConnectionProblem = show
        return view
    }

    func showDateHeaders(_ showDateHeaders: Bool) -> ChatView {
        var view = self
        view.chatCustomizationParameters.showDateHeaders = showDateHeaders
        return view
    }

    func isScrollEnabled(_ isScrollEnabled: Bool) -> ChatView {
        var view = self
        view.chatCustomizationParameters.isScrollEnabled = isScrollEnabled
        return view
    }

    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.chatCustomizationParameters.showMessageMenuOnLongPress = show
        return view
    }

    /// Sets the keyboard dismiss mode for the chat list
    /// - Parameter mode: The keyboard dismiss mode (.interactive, .onDrag, or .none)
    /// - Default is .none
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> ChatView {
        var view = self
        view.chatCustomizationParameters.keyboardDismissMode = mode
        return view
    }

    /// Sets the general duration of various message menu animations
    ///
    /// This value is more akin to 'how snappy' the message menu feels
    /// - Note: Good values are between 0.15 - 0.5 (defaults to 0.3)
    /// - Important: This value is clamped between 0.1 and 1.0
    func messageMenuAnimationDuration(_ duration: Double) -> ChatView {
        var view = self
        view.chatCustomizationParameters.messageMenuAnimationDuration = max(0.1, min(1.0, duration))
        return view
    }

    func contentInsets(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> ChatView {
        var view = self
        if type == .conversation {
            // NOTE: top and bottom are vice versa - because chat is an upside down UITableView
            view.chatCustomizationParameters.contentInsets = UIEdgeInsets(top: bottom, left: left, bottom: top, right: right)
        } else {
            view.chatCustomizationParameters.contentInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        return view
    }

    /// receive scrolling offset updates
    func onContentOffsetChange(_ closure: @escaping (CGFloat) -> Void) -> ChatView {
        var view = self
        view.chatCustomizationParameters.onContentOffsetChange = closure
        return view
    }

    /// scroll to message by id
    func scrollToMessage(_ scrollToParams: ScrollToParams?) -> ChatView {
        var view = self
        view.chatCustomizationParameters.scrollToParams = scrollToParams
        return view
    }

    /// UITableView's will display cell delegate calls this closure
    func onWillDisplayCell(_ closure: @escaping (Message) -> Void) -> ChatView {
        var view = self
        view.chatCustomizationParameters.onWillDisplayCell = closure
        return view
    }

    /// awaitable updates helper similar in usage to `tableView.performBatchUpdates`
    func updateTransaction(_ binding: Binding<TableUpdateTransaction?>) -> ChatView {
        var view = self
        view.chatCustomizationParameters.onTransactionReady = { binding.wrappedValue = $0 }
        return view
    }

    /// when user scrolls up to `pageSize`-th meassage, call the handler function, so user can load more messages
    /// NOTE: doesn't work well with `isScrollEnabled` false
    func enableLoadMore(offset: Int = 0, _ handler: @escaping ()->()) -> ChatView {
        var view = self
        view.chatCustomizationParameters.olderMessagesPaginationHandler = PaginationHandler(offset: offset, handleClosure: handler)
        return view
    }

    /// called when the oldest message appears (if offset is non zero, paginationHandler's offset-th message)
    /// for conversation type chat it's the top-most one
    func enableLoadMoreOlderMessages(paginationHandler: PaginationHandler) -> ChatView {
        var view = self
        view.chatCustomizationParameters.olderMessagesPaginationHandler = paginationHandler
        return view
    }

    /// called when the newest message appears (if offset is non zero, paginationHandler's offset-th message from the end)
    /// for conversation type chat it's the bottom-most one
    func enableLoadMoreNewerMessages(paginationHandler: PaginationHandler) -> ChatView {
        var view = self
        view.chatCustomizationParameters.newerMessagesPaginationHandler = paginationHandler
        return view
    }

    func localization(_ localization: ChatLocalization) -> ChatView {
        var view = self
        view.chatCustomizationParameters.localization = localization
        return view
    }

    /// Sets a delegate for handling and configuring message reactions
    func messageReactionDelegate(_ reactionDelegate: ReactionDelegate) -> ChatView {
        var view = self
        view.chatCustomizationParameters.reactionDelegate = reactionDelegate
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
        view.chatCustomizationParameters.reactionDelegate = DefaultReactionConfiguration(
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
            view.chatCustomizationParameters.listSwipeActions = .init(
                leading: .init(performsFirstActionWithFullSwipe: performsFirstActionWithFullSwipe, actions: items),
                trailing: view.chatCustomizationParameters.listSwipeActions.trailing
            )
        case .trailing:
            view.chatCustomizationParameters.listSwipeActions = .init(
                leading: view.chatCustomizationParameters.listSwipeActions.leading,
                trailing: .init(performsFirstActionWithFullSwipe: performsFirstActionWithFullSwipe, actions: items)
            )
        }
        return view
    }

    // MARK: - Built-in message view

    func showMessageTimeView(_ show: Bool) -> ChatView {
        var view = self
        view.messageCustomizationParameters.showTimeView = show
        return view
    }

    func showUsername(_ show: Bool) -> ChatView {
        var view = self
        view.messageCustomizationParameters.showUsername = show
        return view
    }

    func messageLinkPreviewLimit(_ limit: Int) -> ChatView {
        var view = self
        view.messageCustomizationParameters.linkPreviewLimit = limit
        return view
    }

    func linkPreviewsEnabled(_ enabled: Bool) -> ChatView {
        messageLinkPreviewLimit(enabled ? self.messageCustomizationParameters.linkPreviewLimit : 0)
    }

    func shouldShowPreviewForLink(_ shouldShowPreviewForLink: @escaping (URL) -> Bool) -> ChatView {
        var view = self
        view.messageCustomizationParameters.shouldShowPreviewForLink = shouldShowPreviewForLink
        return view
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageCustomizationParameters.font = font
        return view
    }

    func showAvatar(_ show: Bool) -> ChatView {
        var view = self
        view.messageCustomizationParameters.showAvatar = show
        return view
    }

    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.messageCustomizationParameters.avatarSize = avatarSize
        return view
    }

    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.messageCustomizationParameters.tapAvatarClosure = closure
        return view
    }

    func avatarBuilder<V: View>(_ builder: @escaping (User)->V) -> ChatView {
        var view = self
        view.messageCustomizationParameters.avatarBuilder = { user in
            AnyView(builder(user))
        }
        return view
    }

    // MARK: - Built-in input view

    /// binding to current text in the default input text field
    public func inputViewText(_ binding: Binding<String>) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.externalInputText = binding.wrappedValue
        view.inputViewCustomizationParameters.onInputTextChange = { binding.wrappedValue = $0 }
        return view
    }

    func setAvailableInputs(_ types: [AvailableInputType]) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.availableInputs = types
        return view
    }

    func setRecorderSettings(_ settings: RecorderSettings) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.recorderSettings = settings
        return view
    }

    // MARK: - Media picker

    func setMediaPickerLiveCameraStyle(_ style: MediaPickerLiveCameraStyle) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.mediaPickerParameters.liveCameraStyle = style
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.mediaPickerParameters.selectionParameters.selectionLimit = assetsPickerLimit
        return view
    }

    func setMediaPickerSelectionParameters(_ params: MediaPickerSelectionParameters) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.mediaPickerParameters.selectionParameters = params
        return view
    }

    func orientationHandler(orientationHandler: @escaping MediaPickerOrientationHandler) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.mediaPickerParameters.orientationHandler = orientationHandler
        return view
    }

    func setMediaPickerParameters(_ params: MediaPickerParameters) -> ChatView {
        var view = self
        view.inputViewCustomizationParameters.mediaPickerParameters = params
        return view
    }
}
