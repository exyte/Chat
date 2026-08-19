//
//  View+WindowCover.swift
//  Chat
//
//  Created by Alisa Mylnikova on 19.08.2026.
//

import SwiftUI
import UIKit

extension View {
    func windowCover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(WindowCoverModifier(isPresented: isPresented, coverContent: content))
    }
}

private final class WindowCoverHost: ObservableObject {
    weak var scene: UIWindowScene?
    private var window: UIWindow?

    func show<Content: View>(_ content: Content) {
        guard window == nil, let scene else { return }

        let appFrame: CGRect
        if #available(iOS 15.0, *), let kw = scene.keyWindow {
            appFrame = kw.frame
        } else {
            appFrame = UIApplication.shared.keyWindow?.frame ?? scene.screen.bounds
        }

        let newWindow = UIWindow(windowScene: scene)
        newWindow.windowLevel = .alert
        newWindow.frame = appFrame

        let hostingController = UIHostingController(rootView: AnyView(content))
        hostingController.view.backgroundColor = .clear
        newWindow.rootViewController = hostingController
        newWindow.makeKeyAndVisible()

        newWindow.transform = CGAffineTransform(translationX: 0, y: 1000)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            newWindow.transform = .identity
        }

        window = newWindow
    }

    func hide() {
        guard let w = window else { return }
        window = nil
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            w.transform = CGAffineTransform(translationX: 0, y: 1000)
        } completion: { _ in
            w.resignKey()
            w.windowScene = nil
        }
    }

    deinit {
        window?.resignKey()
        window?.windowScene = nil
    }
}

private struct SceneCaptureView: UIViewRepresentable {
    let onScene: (UIWindowScene) -> Void

    class Coordinator {
        weak var lastScene: UIWindowScene?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> UIView { UIView() }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let scene = uiView.window?.windowScene,
              scene !== context.coordinator.lastScene else { return }
        context.coordinator.lastScene = scene
        onScene(scene)
    }
}

private struct WindowCoverModifier<CoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let coverContent: () -> CoverContent

    @StateObject private var host = WindowCoverHost()

    func body(content: Content) -> some View {
        content
            .background(SceneCaptureView { scene in
                host.scene = scene
            })
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    host.show(coverContent())
                } else {
                    host.hide()
                }
            }
    }
}
