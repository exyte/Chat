//
//  File.swift
//  
//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

private enum AssetPreviewMode {
    case asset(Asset)
    case album(Album)
}

struct AssetPreview: View {
    private let mode: AssetPreviewMode
    
    init(asset: Asset) {
        self.mode = .asset(asset)
    }
    
    init(album: Album) {
        self.mode = .album(album)
    }
    
    var body: some View {
        switch mode {
        case .asset(let asset):
            preview(from: asset.preview)
        case .album(let album):
            VStack {
                preview(from: album.preview)
                if let title = album.title {
                    Text(title)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

private extension AssetPreview {
    var placeholder: some View {
        Rectangle()
            .fill(.gray.opacity(0.6))
            .aspectRatio(1, contentMode: .fill)
    }

    
    @ViewBuilder
    func preview(from data: Data?) -> some View {
        if let data = data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        } else {
            placeholder
        }
    }
}
