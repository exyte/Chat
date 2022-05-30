//
//  File.swift
//  
//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AssetThumbnailView: View {
    let asset: Asset

    init(asset: Asset) {
        self.asset = asset
    }
    
    var body: some View {
        thumbnail(from: asset.thumbnail)
    }
}

private extension AssetThumbnailView {
    @ViewBuilder
    func thumbnail(from thumbnail: Thumbnail?) -> some View {
        if let thumbnail = thumbnail {
#if os(iOS)
            GeometryReader { proxy in
                Image(uiImage: thumbnail.value)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .aspectRatio(1.0, contentMode: .fit)
#else
            ThumbnailPlaceholder() // FIXME: Create preview for other target
#endif
        } else {
            ThumbnailPlaceholder()
        }
    }
}
