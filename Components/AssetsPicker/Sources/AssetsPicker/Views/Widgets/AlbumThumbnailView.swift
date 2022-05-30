//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AlbumThumbnailView: View {
    let album: Album

    init(album: Album) {
        self.album = album
    }
    
    var body: some View {
        VStack {
            thumbnail(from: album.thumbnail)
            if let title = album.title {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private extension AlbumThumbnailView {
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
