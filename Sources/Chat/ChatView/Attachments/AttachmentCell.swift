//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

struct AttachmentCell: View {

    @Environment(\.chatTheme) private var theme

    let attachment: Attachment
    let onTap: (Attachment) -> Void

    var body: some View {
        Group {
            if attachment.type == .image {
                content
            } else if attachment.type == .video {
                content
                    .overlay {
                        theme.images.message.playVideo
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
            } else {
                content
                    .overlay {
                        Text("Unknown")
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(attachment)
        }
    }

    var content: some View {
        AsyncImageView(url: attachment.thumbnail)
    }
}

struct AsyncImageView: View {

    let url: URL

    var body: some View {
        CachedAsyncImage(url: url, urlCache: .imageCache) { imageView in
            imageView
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
        }
    }
}
