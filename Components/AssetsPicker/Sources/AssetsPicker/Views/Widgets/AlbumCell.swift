//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AlbumCell: View {
    let album: AlbumModel
    
#if os(iOS)
    @State private var image: UIImage?
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    init(album: AlbumModel) {
        self.album = album
    }
    
    var body: some View {
        VStack {
            thumbnail
            if let title = album.title {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#if os(iOS)
private extension AlbumCell {
    @ViewBuilder
    var thumbnail: some View {
        if let asset = album.medias.first?.source {
            ThumbnailView(asset: asset, image: $image)
        } else {
            ThumbnailPlaceholder()
        }
    }
}
#endif
