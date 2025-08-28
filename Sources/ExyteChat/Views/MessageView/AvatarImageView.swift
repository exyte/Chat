//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct AvatarImageView: View {

    let url: URL?
    let avatarSize: CGFloat
    var avatarCacheKey: String? = nil

    var body: some View {
        CachedAsyncImage(url: url, cacheKey: avatarCacheKey) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle().fill(Color.gray)
        }
        .viewSize(avatarSize)
        .clipShape(Circle())
    }
}

struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(
            url: URL(string: "https://placeimg.com/640/480/sepia"),
            avatarSize: 32
        )
    }
}
