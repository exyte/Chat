//
//  View+.swift
//
//
//  Created by Alisa Mylnikova on 09.03.2023.
//

import SwiftUI

extension View {
    func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
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

struct CustomDragGesture: ViewModifier {
    let direction:Edge
    let amount: any RangeExpression<CGFloat>
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { val in
                        switch direction {
                        case .top:
                            if amount.contains( -val.translation.height ) { action() }
                        case .leading:
                            if amount.contains( -val.translation.width ) { action() }
                        case .bottom:
                            if amount.contains( val.translation.height ) { action() }
                        case .trailing:
                            if amount.contains( val.translation.width ) { action() }
                        }
                    }
            )
    }
}

extension View {
    /// Adds a Drag Gesture listener on the View that will perform the provided action when a drag ofAmount pixels is performed in the direction indicated
    /// - Parameters:
    ///   - edge: The edge the drag should be towards
    ///   - amount: The number of pixels the drag should traverse in order to trigger the action
    ///   - action: The action to perform when a drag gesture that fits the above criteria is performed
    /// - Returns: The modified view
    public func onDrag(towards edge: Edge, ofAmount amount: any RangeExpression<CGFloat>, perform action: @escaping () -> Void) -> some View {
        modifier(CustomDragGesture(direction: edge, amount: amount, action: action))
    }
}
