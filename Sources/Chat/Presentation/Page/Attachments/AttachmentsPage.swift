//
//  Created by Alex.M on 20.06.2022.
//

import SwiftUI
import CachedAsyncImage

struct AttachmentsPage: View {
    let attachment: any Attachment

    var body: some View {
        if attachment is ImageAttachment {
            CachedAsyncImage(url: attachment.full, urlCache: .imageCache) { imageView in
                imageView
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 100, minHeight: 100)
            }
            .frame(maxHeight: 200)
        } else if let attachment = attachment as? VideoAttachment {
            VideoView(
                viewModel: VideoViewModel(attachment: attachment)
            )
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
