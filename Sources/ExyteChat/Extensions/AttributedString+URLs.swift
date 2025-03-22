//
//  AttributedString+URLs.swift
//  Chat
//
//  Created by Matthew Fennell on 05/03/2025.
//

import Foundation

extension AttributedString {
    public var urls: [URL] {
        runs[\.link].map { (link, range) in
            link?.absoluteURL
        }
        .compactMap { $0 }
    }
}
