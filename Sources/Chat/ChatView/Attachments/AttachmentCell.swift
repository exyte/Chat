//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI
import CachedAsyncImage

struct AttachmentCell: View {

    @Environment(\.chatTheme) private var theme

    let attachment: any Attachment

    var body: some View {
        Group {
            if attachment is ImageAttachment {
                content
            } else if attachment is VideoAttachment {
                content
                    .overlay {
                        theme.images.playButton
                            .foregroundColor(.white)
                            .padding()
                            .background {
                                Circle()
                                    .fill(.black)
                                    .opacity(0.72)
                            }
                    }
            } else {
                content
                    .overlay {
                        Text("Unknown")
                    }
            }
        }
        .contentShape(Rectangle())
    }

    var content: some View {
        CachedAsyncImage(url: attachment.thumbnail, urlCache: .imageCache) { imageView in
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
