//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageTextView: View {
    let text: String?

    @Environment(\.messageUseMarkdown) var messageUseMarkdown

    var body: some View {
        if let text = text, !text.isEmpty {
            textView(text)
                .font(.body)
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        }
    }

    @ViewBuilder
    private func textView(_ text: String) -> some View {
        if messageUseMarkdown,
           let attributed = try? AttributedString(markdown: text) {
            Text(attributed)
        } else {
            Text(text)
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(text: "Hello world!")
    }
}
