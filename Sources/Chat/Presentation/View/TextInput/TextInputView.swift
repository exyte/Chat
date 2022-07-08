//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
    let style: InputViewStyle
    @Binding var text: String

    @State private var uuid = UUID()
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    var body: some View {
        TextField("", text: $text, axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(uuid))
            .placeholder(when: text.isEmpty) {
                Text(style.placeholder)
                    .foregroundColor(Colors.button)
            }
            .foregroundColor(style == .message ? .black : .white)
            .padding(.vertical, 10)
            .onTapGesture {
                globalFocusState.focus = .uuid(uuid)
            }
    }
}
