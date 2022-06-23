//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
    @Binding var text: String

    @State private var uuid = UUID()
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    var body: some View {
        VStack {
            TextField("Message", text: $text, axis: .vertical)
                .frame(minHeight: 35)
                .padding(10)
                .background(.white)
                .cornerRadius(10)
                .padding(3)
                .customFocus($globalFocusState.focus, equals: .uuid(uuid))
                .onTapGesture {
                    globalFocusState.focus = .uuid(uuid)
                }
        }
    }
}

struct TextInputView_Previews: PreviewProvider {
    @State private static var text: String = "Hello world"

    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(Colors.background)
                .ignoresSafeArea()

            TextInputView(text: $text)
        }
    }
}
