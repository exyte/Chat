//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumsView: View {
    let albums: [AlbumModel]
    @Binding var selected: [MediaModel]
    @Binding var isSent: Bool
    
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
                                    medias: album.medias,
                                    selected: $selected,
                                    isSent: $isSent
                                )
                            } label: {
                                AlbumCell(album: album)
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
            trailing: Button("Send") {
                isSent = true
            }
                .disabled(selected.isEmpty)
        )
    }
}
