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
            case .sending, .sent, .delivered:
              getImagge(status)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(getTheme().colors.statusGray)
                    .frame(width: 40)
            case .read:
              getImagge(status)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(getTheme().colors.messageReadStatus)
                    .frame(width: 40)
            case .error:
                Button(action: onRetry) {
                    getTheme().images.message.error
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                }
                .foregroundColor(theme.colors.statusError)
            }
        }
        .viewSize(MessageView.statusViewSize)
        .padding(.trailing, MessageView.horizontalStatusPadding)
    }

    private func getImagge(_ status: Message.Status) -> Image {
        switch status {
        case .sending: return theme.images.message.sending
        case .sent: return theme.images.message.sent
        case .delivered: return theme.images.message.delivered
        case .read: return theme.images.message.read
        case .error: return theme.images.message.error
        }
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
        }
    }
}

