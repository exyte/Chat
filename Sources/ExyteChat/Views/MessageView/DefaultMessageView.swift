import SwiftUI

public struct DefaultMessageView: View {
    let params: MessageBuilderParameters

    @EnvironmentObject private var viewModel: ChatViewModel
    @Environment(\.chatMessageType) private var chatType
    @Environment(\.messageCustomizationParams) private var customizationParams
    @Environment(\.timeViewWidthBinding) private var timeViewWidth
    @Environment(\.isDisplayingMessageMenu) private var isDisplayingMessageMenu

    public init(params: MessageBuilderParameters) {
        self.params = params
    }

    public var body: some View {
        MessageView(
            viewModel: viewModel,
            message: params.message,
            positionInUserGroup: params.positionInGroup,
            positionInMessagesSection: params.positionInMessagesSection,
            chatType: chatType,
            params: customizationParams,
            timeViewWidth: timeViewWidth,
            isDisplayingMessageMenu: isDisplayingMessageMenu
        )
    }
}
