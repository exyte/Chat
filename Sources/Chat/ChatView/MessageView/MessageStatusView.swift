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
                theme.images.sendingStatus
                    .resizable()
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(90))
                    .foregroundColor(theme.colors.grayStatus)
            case .sent:
                theme.images.sentStatus
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(theme.colors.grayStatus)
            case .read:
                theme.images.sentStatus
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(theme.colors.myMessage)
            case .error:
                Button {
                    onRetry()
                } label: {
                    theme.images.errorStatus
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .foregroundColor(theme.colors.errorStatus)
            }
        }
        .padding(.trailing, 8)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageStatusView(status: .sending, onRetry: {})
            MessageStatusView(status: .error, onRetry: {})
            MessageStatusView(status: .sent, onRetry: {})
            MessageStatusView(status: .read, onRetry: {})
        }
    }
}
