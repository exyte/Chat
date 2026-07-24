//
//  URL+Extensions.swift
//  Chat
//
//  Created by Exyte on 23.07.2026.
//

import Foundation

extension URL {
    var isGIF: Bool {
        pathExtension.lowercased() == "gif"
    }
}
