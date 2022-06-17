//
//  Created by Alex.M on 17.06.2022.
//

import SwiftUI

struct MessageContainer<Content>: View where Content: View {
    let author: Author
    @ViewBuilder var content: () -> Content

    let imageSize = 30.0 // TODO: Create config for avatar size

    var body: some View {
        HStack(alignment: .bottom) {
            if author.isCurrentUser {
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
        AsyncImage(url: author.avatarURL) { image in
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
                    .foregroundColor(author.isCurrentUser ? Colors.myMessage : Colors.friendMessage)
            )
    }
}
