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
    let userType: UserType

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

        result.foregroundColor = theme.colors.messageText(userType)

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
            userType: .other)
        MessageTextView(
            text: "Look at [this website](https://example.org)", messageUseMarkdown: false,
            userType: .other)
    }
}
