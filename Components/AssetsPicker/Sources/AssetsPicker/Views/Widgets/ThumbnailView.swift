//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI
import Photos

struct ThumbnailView: View {
    let asset: PHAsset
#if os(iOS)
    @Binding var image: UIImage?
#else
    // FIXME: Create preview for image/video for other platforms
#endif

    var body: some View {
        content
    }
}

// MARK: - iOs thumbnail
#if os(iOS)
private extension ThumbnailView {
    func fetchPreview(size: CGSize) {
        if image == nil {
            Task {
                self.image = await AssetUtils.image(from: asset, size: size)
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if let image = image {
            GeometryReader { proxy in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .aspectRatio(1.0, contentMode: .fit)
        } else {
            GeometryReader { proxy in
                ThumbnailPlaceholder()
                    .onAppear {
                        let size = min(proxy.size.height, proxy.size.width) * UIScreen.main.scale * 1.4
                        fetchPreview(size: CGSize(width: size, height: size))
                    }
            }
        }
    }
}
#endif
