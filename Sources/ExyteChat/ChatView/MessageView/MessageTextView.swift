//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageTextView: View {

    @Environment(\.chatTheme) private var theme

    let text: String?
    let messageUseMarkdown: Bool
    let isCurrentUser: Bool

    var styledText: AttributedString {
        let textToStyle = text ?? ""

        var result =
            if messageUseMarkdown,
                let attributed = try? AttributedString(
                    markdown: textToStyle, options: String.markdownOptions)
            {
                attributed
            } else {
                AttributedString(stringLiteral: textToStyle)
            }

        let color =
            isCurrentUser ? theme.colors.messageMyText : theme.colors.messageFriendText
        result.foregroundColor = color

        for (link, range) in result.runs[\.link] {
            if link != nil {
                result[range].underlineStyle = .single
            }
        }

        return result
    }

    var body: some View {
        if !styledText.characters.isEmpty {
            Text(styledText)
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(
            text: "Look at [this website](https://example.org)", messageUseMarkdown: true,
            isCurrentUser: false)
        MessageTextView(
            text: "Look at [this website](https://example.org)", messageUseMarkdown: false,
            isCurrentUser: false)
    }
}
