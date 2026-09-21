//
//  Image+Extensions.swift
//
//
//  Created by Alisa Mylnikova on 21.09.2026.
//

import SwiftUI

extension Image {
    /// Resizable, template-rendered icon tinted to a single color and squared to `size`.
    @MainActor
    func sizeAndColor(_ size: CGFloat, _ color: Color, contentMode: ContentMode = .fit) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: contentMode)
            .foregroundColor(color)
            .viewSize(size)
    }
}
