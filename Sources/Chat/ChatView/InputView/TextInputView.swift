//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {

    @Environment(\.chatTheme) private var theme

    @Binding var text: String
    let style: InputViewStyle

    @State private var uuid = UUID()
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    var body: some View {
        TextField("", text: $text, axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(uuid))
            .placeholder(when: text.isEmpty) {
                Text(style.placeholder)
                    .foregroundColor(theme.colors.buttonBackground)
            }
            .foregroundColor(style == .message ? theme.colors.textLightContext : theme.colors.textDarkContext)
            .padding(.vertical, 10)
            .onTapGesture {
                globalFocusState.focus = .uuid(uuid)
            }
    }
}
