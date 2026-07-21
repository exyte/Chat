//
//  CachedAnimatedImage.swift
//

import SwiftUI
import Kingfisher

struct CachedAnimatedImage<Placeholder: View>: View {

    let url: URL
    let cacheKey: String?
    let contentMode: SwiftUI.ContentMode
    @ViewBuilder var placeholder: () -> Placeholder

    var body: some View {
        // `.network(...)` only works for http(s) URLs; local `file://` URLs (e.g. GIFs picked
        // from the photo library) need `.provider(LocalFileImageDataProvider)`, which
        // `convertToSource` picks automatically based on the URL scheme.
        KFAnimatedImage(source: url.convertToSource(overrideCacheKey: cacheKey))
            .configure { view in
#if canImport(UIKit)
                view.contentMode = contentMode == .fill ? .scaleAspectFill : .scaleAspectFit
                view.clipsToBounds = true
#elseif canImport(AppKit)
                view.imageScaling = .scaleProportionallyUpOrDown
#endif
            }
            .cacheOriginalImage()
            .placeholder(placeholder)
    }
}

extension URL {
    var isGIF: Bool {
        pathExtension.lowercased() == "gif"
    }
}
