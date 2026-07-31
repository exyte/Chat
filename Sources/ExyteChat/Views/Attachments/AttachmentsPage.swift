//
//  Created by Alex.M on 20.06.2022.
//

import SwiftUI

struct AttachmentsPage: View {

    @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
    @Environment(\.chatTheme) private var theme

    let attachment: Attachment

    var body: some View {
        if attachment.type == .image {
            ZoomableContainer {
                if attachment.full.isGIF {
                    CachedAnimatedImage(
                        url: attachment.full,
                        cacheKey: attachment.fullCacheKey,
                        contentMode: .fit
                    ) {
                        ActivityIndicator()
                    }
                } else {
                    CachedAsyncImage(
                        url: attachment.full,
                        cacheKey: attachment.fullCacheKey
                    ) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ActivityIndicator()
                        }
                    }
                }
            }
        } else if attachment.type == .video {
            VideoView(viewModel: VideoViewModel(attachment: attachment))
        } else if attachment.type == .document {
            documentView
        } else {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
                .frame(maxHeight: 200)
                .overlay {
                    Text("Unknown", bundle: .module)
                }
        }
    }

    private var documentView: some View {
        VStack(spacing: 16) {
            theme.images.message.attachedDocument
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.white)
            Text(attachment.fileName ?? attachment.full.lastPathComponent)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button {
                UIApplication.shared.open(attachment.full)
            } label: {
                Text("Open", bundle: .module)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .foregroundColor(.white)
            }
        }
    }
}
