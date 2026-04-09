//
//  String+Style.swift
//  Chat
//
//  Created by Matthew Fennell on 01/03/2025.
//

import Foundation

extension String {

    private static var markdownOptions = AttributedString.MarkdownParsingOptions(
        allowsExtendedAttributes: false,
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible,
        languageCode: nil
    )
    
    func applyDefaultAttributes() -> AttributedString {
        var result = (try? AttributedString(markdown: self, options: String.markdownOptions)) ?? AttributedString(stringLiteral: self)

        for (link, range) in result.runs[\.link] {
            if link != nil {
                result[range].underlineStyle = .single
            }
        }

        return result
    }
}
