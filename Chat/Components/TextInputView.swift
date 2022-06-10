//
//  TextInputView.swift
//  Chat
//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
    @Binding var text: String

    var body: some View {
        VStack {
            TextField("", text: $text, axis: .vertical)
                .frame(minHeight: 35)
                .padding(10)
                .background(.white)
                .cornerRadius(10)
                .padding(3)
        }
    }
}

struct TextInputView_Previews: PreviewProvider {
    @State private static var text: String = "Hello world"

    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "EEEEEE"))
                .ignoresSafeArea()

            TextInputView(text: $text)
        }
    }
}
