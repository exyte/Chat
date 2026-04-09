//
//  Created by Alex.M on 08.07.2022.
//

import SwiftUI

struct MessageTimeView: View {
    @Environment(\.chatTheme) var theme

    let text: String
    let userType: UserType

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(theme.colors.messageTimeText(userType))
    }
}

struct MessageTimeWithCapsuleView: View {
    let text: String
    let isCurrentUser: Bool

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white)
            .opacity(0.8)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .foregroundColor(.black.opacity(0.4))
            }
    }
}

