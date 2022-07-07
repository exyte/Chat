//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageStatusView: View {
    let status: Message.Status
    let onRetry: () -> Void

    var body: some View {
        Group {
            switch status {
            case .sending:
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(90))
                    .foregroundColor(Colors.grayStatus)
            case .sent:
                Image("checkmarks", bundle: .current)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Colors.grayStatus)
            case .read:
                Image("checkmarks", bundle: .current)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Colors.myMessage)
            case .error:
                Button {
                    onRetry()
                } label: {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .foregroundColor(.red)
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
