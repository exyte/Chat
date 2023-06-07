//
//  Created by Alex.M on 20.06.2022.
//

import SwiftUI

struct AttachmentsPage: View {

    @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
    @Environment(\.chatTheme) private var theme

    let attachment: any Attachment

    var body: some View {
        if attachment is ImageAttachment {
            CachedAsyncImage(url: attachment.full, urlCache: .imageCache) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Color.clear
                }
            }
        } else if let attachment = attachment as? VideoAttachment {
            VideoView(viewModel: VideoViewModel(attachment: attachment))
        } else {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
                .frame(maxHeight: 200)
                .overlay {
                    Text("Unknown")
                }
        }
    }
}
