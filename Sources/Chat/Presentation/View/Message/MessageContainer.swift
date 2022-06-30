//
//  Created by Alex.M on 17.06.2022.
//

import SwiftUI
import CachedAsyncImage

struct MessageContainer<Content>: View where Content: View {
    let user: User
    @ViewBuilder var content: () -> Content

    let imageSize = 30.0 // TODO: Create config for avatar size

    var body: some View {
        HStack(alignment: .bottom) {
            if user.isCurrentUser {
                Spacer(minLength: 40)
                contentView
                avatar
            } else {
                avatar
                contentView
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 8)
    }

    var avatar: some View {
        CachedAsyncImage(url: user.avatarURL, urlCache: .imageCache) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .mask {
                    Circle()
                }
        } placeholder: {
            Circle().foregroundColor(Color.gray)
                .frame(width: imageSize, height: imageSize)
        }
    }

    var contentView: some View {
        content()
            .mask {
                RoundedRectangle(cornerRadius: 15)
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(user.isCurrentUser ? Colors.myMessage : Colors.friendMessage)
            )
    }
}
