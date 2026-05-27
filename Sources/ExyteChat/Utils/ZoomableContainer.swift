//
//  ZoomableContainer.swift
//  Chat
//
//  Created by Thilo Molitor on 10.10.2023.
//

import SwiftUI

public struct ZoomableContainer<Content: View>: View {
    let content: Content
    let maxScale: CGFloat
    let doubleTapScale: CGFloat
    @State private var currentScale: CGFloat = 1.0
    @State private var tapLocation: CGPoint = .zero

    public init(maxScale:CGFloat = 4.0, doubleTapScale:CGFloat = 4.0, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
    }

    public var body: some View {
        ZoomableScrollView(maxScale: maxScale, scale: $currentScale, tapLocation: $tapLocation) {
            content
        }
        .onTapGesture(count: 2, perform: { location in
            tapLocation = location
            currentScale = currentScale == 1.0 ? doubleTapScale : 1.0
        })
    }

    fileprivate struct ZoomableScrollView<InnerContent: View>: UIViewRepresentable {
        private var content: InnerContent
        let maxScale: CGFloat
        @Binding private var currentScale: CGFloat
        @Binding private var tapLocation: CGPoint

        init(maxScale: CGFloat, scale: Binding<CGFloat>, tapLocation: Binding<CGPoint>, @ViewBuilder content: () -> InnerContent) {
            self.maxScale = maxScale
            _currentScale = scale
            _tapLocation = tapLocation
            self.content = content()
        }

        func makeUIView(context: Context) -> UIScrollView {
            // Setup the UIScrollView
            let scrollView = UIScrollView()
            scrollView.delegate = context.coordinator // for viewForZooming(in:)
            scrollView.maximumZoomScale = maxScale
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false

            // Create a UIHostingController to hold our SwiftUI content
            let hostedView = context.coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = true
            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostedView.frame = scrollView.bounds
            scrollView.addSubview(hostedView)

            return scrollView
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(hostingController: UIHostingController(rootView: content), scale: $currentScale)
        }

        func updateUIView(_ uiView: UIScrollView, context: Context) {
            // Update the hosting controller's SwiftUI content
            context.coordinator.hostingController.rootView = content

            if uiView.zoomScale > uiView.minimumZoomScale { // Scale out
                uiView.setZoomScale(currentScale, animated: true)
            } else if tapLocation != .zero { // Scale in to a specific point
                uiView.zoom(to: zoomRect(for: uiView, scale: uiView.maximumZoomScale, center: tapLocation), animated: true)
            }

            // Reset the location to prevent scaling to it in case of a negative scale (manual pinch)
            // Use the main thread to prevent unexpected behavior
            DispatchQueue.main.async { tapLocation = .zero }

            assert(context.coordinator.hostingController.view.superview == uiView)
        }

        // MARK: - Utils

        func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
            let scrollViewSize = scrollView.bounds.size

            let width = scrollViewSize.width / scale
            let height = scrollViewSize.height / scale
            let x = center.x - (width / 2.0)
            let y = center.y - (height / 2.0)

            return CGRect(x: x, y: y, width: width, height: height)
        }

        // MARK: - Coordinator

        class Coordinator: NSObject, UIScrollViewDelegate {
            var hostingController: UIHostingController<InnerContent>
            @Binding var currentScale: CGFloat

            init(hostingController: UIHostingController<InnerContent>, scale: Binding<CGFloat>) {
                self.hostingController = hostingController
                _currentScale = scale
            }

            func viewForZooming(in scrollView: UIScrollView) -> UIView? {
                return hostingController.view
            }

            func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
                currentScale = scale
            }
        }
    }
}
