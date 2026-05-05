//
//  ChatCustomizationParameters.swift
//  Chat
//
//  Created by Alisa Mylnikova on 02.04.2026.
//

import SwiftUI
import ExyteMediaPicker

struct ChatCustomizationParameters {
    var isListAboveInputView: Bool = true
    var showScrollToBottomButton: Bool = true
    var showNetworkConnectionProblem: Bool = false
    var showDateHeaders: Bool = true
    var isScrollEnabled: Bool = true
    var showMessageMenuOnLongPress: Bool = true
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none
    var messageMenuAnimationDuration: CGFloat = 0.3
    var contentInsets: UIEdgeInsets = .zero

    var scrollToParams: ScrollToParams?
    var onContentOffsetChange: ((CGFloat) -> Void)? // Internal → External
    var onWillDisplayCell: ((Message) -> Void)?
    var onTransactionReady: ((TableUpdateTransaction) -> Void)?

    var olderMessagesPaginationHandler: PaginationHandler?
    var newerMessagesPaginationHandler: PaginationHandler?
    var localization = ChatLocalization.defaultLocalization // these can be localized in the Localizable.strings files
    var reactionDelegate: ReactionDelegate?
    var listSwipeActions = ListSwipeActions()
}

public struct ScrollToParams: Equatable {
    enum ScrollTo: Equatable {
        case messageID(messageID: String, position: UITableView.ScrollPosition, offset: CGFloat)
        case tableOffset(CGFloat)
    }

    let scrollTo: ScrollTo

    public init(messageID: String, position: UITableView.ScrollPosition, offset: CGFloat = 0) {
        self.scrollTo = .messageID(messageID: messageID, position: position, offset: offset)
    }

    public init(offset: CGFloat) {
        self.scrollTo = .tableOffset(offset)
    }
}

struct MessageCustomizationParameters {
    var showTimeView = true
    var showUsername = false
    var linkPreviewLimit = 8
    var shouldShowPreviewForLink: (URL) -> Bool = { _ in true }
    var font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))

    // avatar
    var showAvatar = true
    var avatarSize: CGFloat = 32
    var tapAvatarClosure: ChatView.TapAvatarClosure?
    var avatarBuilder: ((User)->(AnyView))?
}

struct InputViewCustomizationParameters {
    var externalInputText: String? // External → Internal
    var onInputTextChange: ((String) -> Void)? // Internal → External
    var availableInputs: [AvailableInputType] = [.text, .audio, .media]
    var recorderSettings = RecorderSettings()
    var mediaPickerParameters = MediaPickerParameters()
}

public typealias MediaPickerParameters = ExyteMediaPicker.MediaPickerCutomizationParameters
