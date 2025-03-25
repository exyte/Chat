//
//  DynamicTypeSize+BubbleDiameter.swift
//  Chat
//

import SwiftUI

extension DynamicTypeSize {
    /// These values were extracted from a single emoji rendered at `Font.title3`
    /// We use these values to help with view layouts and frames
    func bubbleDiameter() -> CGFloat {
        switch self {
        case .xSmall:
            return 22
        case .small:
            return 23
        case .medium:
            return 24
        case .large:
            return 25
        case .xLarge:
            return 26
        case .xxLarge:
            return 27
        case .xxxLarge:
            return 30
        case .accessibility1:
            return 35
        case .accessibility2:
            return 42
        case .accessibility3:
            return 48
        case .accessibility4:
            return 53
        case .accessibility5:
            return 59
        @unknown default:
            return 25
        }
    }
}
