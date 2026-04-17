import SwiftUI

struct DefaultMessageView: View {
    let params: MessageBuilderParameters

    @EnvironmentObject private var viewModel: ChatViewModel
    @Environment(\.chatMessageType) private var chatType
    @Environment(\.messageCustomizationParams) private var customizationParams
    @Environment(\.timeViewWidthBinding) private var timeViewWidth
    @Environment(\.reactionViewWidthBinding) private var reactionViewWidth

    init(params: MessageBuilderParameters) {
        self.params = params
    }

    var body: some View {
        MessageView(
            viewModel: viewModel,
            message: params.message,
            positionInUserGroup: params.positionInGroup,
            positionInMessagesSection: params.positionInMessagesSection,
            chatType: chatType,
            params: customizationParams,
            timeViewWidth: timeViewWidth,
            reactionViewWidth: reactionViewWidth,
            isDisplayingMessageMenu: false
        )
    }
}
