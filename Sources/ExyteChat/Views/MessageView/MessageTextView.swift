//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

@MainActor
struct MessageTextView: View {

    @Environment(\.chatTheme) private var theme

    /// If the message contains links, this property is used to correctly size the link previews, so they have the same width as the message text.
    @State private var textSize: CGSize = .zero

    /// Large enough to show the domain and icon, if needed, for most pages.
    private static let minLinkPreviewWidth: CGFloat = 140

    let text: String
    let messageStyler: (String) -> AttributedString
    let userType: UserType
    let shouldShowLinkPreview: (URL) -> Bool
    let messageLinkPreviewLimit: Int

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

    var urlsToPreview: [URL] {
        Array(styledText.urls.filter(shouldShowLinkPreview).prefix(messageLinkPreviewLimit))
    }

    var body: some View {
        if !styledText.characters.isEmpty {
            VStack(alignment: .leading) {
                Text(styledText)
                    .sizeGetter($textSize)

                // We use .enumerated(), and \.offset as the id, so that a message with duplicate links will show a preview for each.
                if !urlsToPreview.isEmpty {
                    VStack {
                        ForEach(Array(urlsToPreview.enumerated()), id: \.offset) { _, url in
                            LinkPillView(url: url)
                        }
                    }
                    .frame(width: max(textSize.width, Self.minLinkPreviewWidth))
                }
            }
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(
            text: "Look at [this website](https://example.org)",
            messageStyler: AttributedString.init, userType: .other,
            shouldShowLinkPreview: { _ in true }, messageLinkPreviewLimit: 8)
        MessageTextView(
            text: "Look at [this website](https://example.org)",
            messageStyler: String.markdownStyler, userType: .other,
            shouldShowLinkPreview: { _ in true }, messageLinkPreviewLimit: 8)
        MessageTextView(
            text: "[@Dan](mention://user/123456789) look at [this website](https://example.org)!",
            messageStyler: String.markdownStyler, userType: .other,
            shouldShowLinkPreview: { $0.scheme != "mention" }, messageLinkPreviewLimit: 8)
    }
}
