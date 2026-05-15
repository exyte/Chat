//
//  View+StatusBar.swift
//  
//
//  Created by Alisa Mylnikova on 02.06.2023.
//

import SwiftUI
import UIKit
import Combine

extension UIStatusBarManager {
    public static var statusBarTappedNotification: Notification.Name = {
        if let originalMethod = class_getInstanceMethod(UIStatusBarManager.self, Selector(("handleTapAction:"))),
           let swizzledMethod = class_getInstanceMethod(UIStatusBarManager.self, #selector(_handleTapAction)) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        return .init("statusBarSelected")
    }()

    @objc private func _handleTapAction(_ action: Any?) {
        _handleTapAction(action) // Call the original implementation
        NotificationCenter.default.post(name: UIStatusBarManager.statusBarTappedNotification, object: nil)
    }
}

struct StatusBarTapModifier: ViewModifier {

    let action: () -> Void

    @State private var observer: AnyCancellable?

    func body(content: Content) -> some View {
        content
            .onAppear {
                observer = NotificationCenter.default
                    .publisher(for: UIStatusBarManager.statusBarTappedNotification)
                    .sink { _ in
                        action()
                    }
            }
            .onDisappear {
                observer = nil
            }
    }
}

extension View {
    func onStatusBarTap(_ action: @escaping () -> Void) -> some View {
        modifier(StatusBarTapModifier(action: action))
    }
}
