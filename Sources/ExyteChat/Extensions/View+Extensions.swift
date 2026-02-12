//
//  View+.swift
//
//
//  Created by Alisa Mylnikova on 09.03.2023.
//

import SwiftUI

extension View {
    /// Results in a square of the specified size
    func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
    
    /// Results in a rectangle with the width specified and a height of 1 pixel
    func viewWidth(_ width: CGFloat) -> some View {
        self.frame(width: width, height: 1)
    }

    func circleBackground(_ color: Color) -> some View {
        self.background {
            Circle().fill(color)
        }
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
