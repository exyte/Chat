//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

struct AvatarView: View {

	let avatar: User.Avatar?
    let avatarSize: CGFloat

    var body: some View {
		switch avatar {
		case .remote(let url):
			CachedAsyncImage(url: url, urlCache: .imageCache) { image in
				image
					.resizable()
					.scaledToFill()
			} placeholder: {
				Rectangle().fill(Color.gray)
			}
			.viewSize(avatarSize)
			.clipShape(Circle())
		case .image(let image):
			Image(uiImage: image)
				.resizable()
				.scaledToFill()
				.viewSize(avatarSize)
				.clipShape(Circle())
		case .none: Rectangle().fill(Color.gray)
		}
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(
			avatar: .remote(URL(string: "https://placeimg.com/640/480/sepia")!),
            avatarSize: 32
        )
    }
}
