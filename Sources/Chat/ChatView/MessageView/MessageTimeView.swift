//
//  Created by Alex.M on 08.07.2022.
//

import SwiftUI

struct MessageTimeView: View {
    let text: String
    let isCurrentUser: Bool
    let isOverlay: Bool

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(textColor)
            .opacity(isOverlay ? 0.8 : 0.4)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                if isOverlay {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.black)
                        .opacity(0.4)
                }
            }
            .clipShape(Capsule())
    }

    var textColor: Color {
        isOverlay || isCurrentUser ? .white : .black
    }
}
