//
//  AvatarView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 19.06.2023.
//

import SwiftUI
import ExyteChat

struct AvatarView: View {
    let url: URL?
    let size: CGFloat
    var avatarCacheKey: String? = nil

    var body: some View {
        if let url {
            CachedAsyncImage(url: url, cacheKey: avatarCacheKey) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(.placeholderAvatar)
                    .resizable()
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            Image(.placeholderAvatar)
                .resizable()
                .frame(width: size, height: size)
        }
    }
}
