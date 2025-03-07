//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct MessageTextView: View {

    @Environment(\.chatTheme) private var theme

    let text: String
    let messageStyler: (String) -> AttributedString
    let userType: UserType

    var styledText: AttributedString {
        var result = text.styled(using: messageStyler)
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
        MessageTextView(text: "Look at [this website](https://example.org)", messageStyler: AttributedString.init, userType: .other)
        MessageTextView(text: "Look at [this website](https://example.org)", messageStyler: String.markdownStyler, userType: .other)
    }
}
