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

    /// Large enough to show the domain and icon, if needed, for most pages.
    private static let minLinkPreviewWidth: CGFloat = 140

    let attributedText: AttributedString
    let userType: UserType
    let params: MessageCustomizationParameters

    var previewLinks: [URL] {
        Array(attributedText.urls.filter(params.shouldShowPreviewForLink).prefix(params.linkPreviewLimit))
    }

    var body: some View {
        if !attributedText.characters.isEmpty {
            VStack(alignment: .leading) {
                Text(attributedText)
                    .foregroundStyle(theme.colors.messageText(userType))

                if !previewLinks.isEmpty {
                    VStack(alignment: userType == .current ? .trailing : .leading) {
                        // We use .enumerated(), and \.offset as the id, so that a message with duplicate links will show a preview for each.
                        ForEach(Array(previewLinks.enumerated()), id: \.offset) { _, url in
                            LinkPreviewView(url: url)
                        }
                    }
                    .frame(minWidth: Self.minLinkPreviewWidth)
                }
            }
            .font(Font(params.font as CTFont))
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(
            attributedText: .init("Look at [this website](https://example.org)"), // no markdown
            userType: .other,
            params: MessageCustomizationParameters(
                shouldShowPreviewForLink: { _ in true }
            ))
        MessageTextView(
            attributedText: "Look at [this website](https://example.org)",
            userType: .other,
            params: MessageCustomizationParameters(
                shouldShowPreviewForLink: { _ in true }
            )
        )
        MessageTextView(
            attributedText: "[@Dan](mention://user/123456789) look at [this website](https://example.org)!",
            userType: .other,
            params: MessageCustomizationParameters(
                shouldShowPreviewForLink: { $0.scheme != "mention" }
            ))
    }
}
