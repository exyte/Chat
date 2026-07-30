//
//  LastReadIndicatorView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 28.07.2026.
//

import SwiftUI

struct LastReadIndicatorView: View {

    @Environment(\.chatTheme) var theme

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.colors.statusError.opacity(0.3))

            Text("New messages")
                .font(.caption)
                .foregroundColor(theme.colors.statusError.opacity(0.7))
                .fixedSize()

            Rectangle()
                .frame(height: 1)
                .foregroundColor(theme.colors.statusError.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
}
