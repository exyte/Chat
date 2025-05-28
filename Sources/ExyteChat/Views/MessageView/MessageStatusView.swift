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
                theme.images.message.sending
                    .resizable()
                    .foregroundColor(getTheme().colors.statusGray)
            case .sent:
                theme.images.message.sent
                    .resizable()
                    .foregroundColor(getTheme().colors.messageMyBG)
            case .read:
                theme.images.message.read
                    .resizable()
                    .foregroundColor(getTheme().colors.messageMyBG)
            case .error:
                Button {
                    onRetry()
                } label: {
                    getTheme().images.message.error
                        .resizable()
                }
                .foregroundColor(theme.colors.statusError)
            }
        }
        .viewSize(MessageView.statusViewSize)
        .padding(.trailing, MessageView.horizontalStatusPadding)
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
            MessageStatusView(status: .read, onRetry: {})
        }
    }
}
