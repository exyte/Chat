//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AlbumCell: View {
    @StateObject var viewModel: AlbumViewModel
    
    var body: some View {
        VStack {
            ThumbnailView(preview: viewModel.preview)
                .aspectRatio(1, contentMode: .fill)
            if let title = viewModel.album.title {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            viewModel.fetchPreview()
        }
    }
}
