//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageStatusView: View {

    @Environment(\.chatTheme) private var theme

    let status: Message.Status
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch status {
            case .sending:
                statusImageStyled(image: theme.images.message.sending, color: getTheme().colors.statusGray)
            case .sent:
                statusImageStyled(image: theme.images.message.sent, color: getTheme().colors.statusGray)
            case .delivered:
                statusImageStyled(image: theme.images.message.delivered, color: getTheme().colors.statusGray)
            case .read:
                statusImageStyled(image: theme.images.message.read, color: getTheme().colors.messageReadStatus)
            case .error:
                Button(action: onRetry) {
                    statusImageStyled(image: theme.images.message.error, color: getTheme().colors.statusError)
                }
            }
        }
        .viewSize(MessageView.statusViewSize)
        .padding(.trailing, MessageView.horizontalStatusPadding)
    }

    private func statusImageStyled(image: Image, color: Color) -> some View {
        return
            image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
            .frame(width: 40)
    }

    @MainActor
    private func getTheme() -> ChatTheme {
        return theme
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            MessageStatusView(status: .sending, onRetry: {})
            MessageStatusView(status: .sent, onRetry: {})
            MessageStatusView(status: .delivered, onRetry: {})
            MessageStatusView(status: .read, onRetry: {})
            MessageStatusView(status: .error(emptyDraft()), onRetry: {})
        }
    }

    private static func emptyDraft() -> DraftMessage {
        return DraftMessage(
            id: nil,
            text: "",
            medias: [],
            giphyMedia: nil,
            recording: nil,
            replyMessage: nil,
            createdAt: Date()
        )

    }
}
