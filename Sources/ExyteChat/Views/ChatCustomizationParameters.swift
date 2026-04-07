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

    var externalContentOffset: CGPoint? // External → Internal
    var onContentOffsetChange: ((CGPoint) -> Void)? // Internal → External
    var scrollToMessageID: String?
    var onWillDisplayCell: ((Message) -> Void)?
    var onTransactionReady: ((TableUpdateTransaction) -> Void)?

    var paginationHandler: PaginationHandler?
    var localization = ChatLocalization.defaultLocalization // these can be localized in the Localizable.strings files
    var reactionDelegate: ReactionDelegate?
    var listSwipeActions = ListSwipeActions()
}

struct MessageCustomizationParameters {
    var showTimeView = true
    var showUsername = false
    var showAvatar = true
    var avatarSize: CGFloat = 32
    var tapAvatarClosure: ChatView.TapAvatarClosure?
    var linkPreviewLimit = 8
    var shouldShowPreviewForLink: (URL) -> Bool = { _ in true }
    var font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var styler: (String) -> AttributedString = AttributedString.init
}

struct InputViewCustomizationParameters {
    var externalInputText: String? // External → Internal
    var onInputTextChange: ((String) -> Void)? // Internal → External
    var availableInputs: [AvailableInputType] = [.text, .audio, .media]
    var recorderSettings = RecorderSettings()
    var mediaPickerParameters = MediaPickerParameters()
}

public typealias MediaPickerParameters = ExyteMediaPicker.MediaPickerCutomizationParameters
