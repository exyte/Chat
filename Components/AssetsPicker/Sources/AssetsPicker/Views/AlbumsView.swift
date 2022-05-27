//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumsView: View {
    @Binding var albums: [Album]
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    private var cellPadding: EdgeInsets {
        EdgeInsets(top: 2, leading: 2, bottom: 8, trailing: 2)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if albums.isEmpty {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(albums) { album in
                                VStack {
                                    if let cover = album.cover {
                                        Image(uiImage: cover)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                    } else {
                                        Rectangle()
                                            .fill(.gray.opacity(0.6))
                                            .aspectRatio(1, contentMode: .fill)
                                    }
                                    
                                    Text(album.title ?? "No title")
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(cellPadding)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Albums")
        }
    }
}

struct AlbumsView_Preview: PreviewProvider {
    @State static var albums: [Album] = [
        Album(title: "Example"),
        Album(title: "Example 2"),
        Album(title: "Example 3"),
        Album(title: "Example 4"),
        Album(title: "Example Example Example"),
        Album(title: "Example Example Example 2"),
        Album(title: "Example 5"),
    ]
    
    static var previews: some View {
        AlbumsView(albums: $albums)
    }
}
