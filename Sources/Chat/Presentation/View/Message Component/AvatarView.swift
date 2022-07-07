//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI
import CachedAsyncImage

struct AvatarView: View {
    let url: URL?
    let hideAvatar: Bool

    let avatarSize = 32.0 // TODO: Create config for avatar size

    var body: some View {
        CachedAsyncImage(url: url, urlCache: .imageCache) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: avatarSize, height: avatarSize)
                .mask {
                    Circle()
                }
        } placeholder: {
            Circle().foregroundColor(Color.gray)
                .frame(width: avatarSize, height: avatarSize)
        }
        .hidden(hideAvatar)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(
            url: URL(string: "https://placeimg.com/640/480/sepia"),
            hideAvatar: false
        )
    }
}
