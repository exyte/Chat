//
//  LiveLocationStatusText.swift
//  Chat
//

import SwiftUI

struct LiveLocationStatusText: View {
    @Environment(\.chatLocalization) var localization

    var isActive: Bool
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isActive ? localization.liveLocationText : localization.liveLocationEndedText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            if isActive, let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .monospacedDigit()
                    .lineLimit(1)
            }
        }
    }
}
