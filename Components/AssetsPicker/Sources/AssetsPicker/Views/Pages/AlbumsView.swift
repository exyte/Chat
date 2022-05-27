//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumsView: View {
    let albums: [Album]
    @Binding var selected: [String]
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    private var cellPadding: EdgeInsets {
        EdgeInsets(top: 2, leading: 2, bottom: 8, trailing: 2)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if albums.isEmpty {
                    ProgressView()
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(albums) { album in
                            NavigationLink {
                                AlbumView(
                                    title: album.title,
                                    assets: album.assets,
                                    selected: $selected
                                )
                            } label: {
                                AssetPreview(album: album)
                                    .padding(cellPadding)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarItems(
            trailing: Button("Send") {}
                .disabled(selected.isEmpty)
        )
    }
}
