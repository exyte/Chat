//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import UIKit

public struct AssetPicker: View {
    @Binding public var openPicker: Bool

    @StateObject var provider = PhotoProviderService()
    @State var selected: [Int] = []
    
    public init(openPicker: Binding<Bool>) {
        self._openPicker = openPicker
    }
    
    public var body: some View {
        TabView {
            allPhotosView
            albumsView
        }
        .onAppear {
            Task {
                await provider.fetchAllPhotos()
                await provider.fetchAlbums()
            }
        }
    }
}

private extension AssetPicker {
    var allPhotosView: some View {
        let view = AllPhotosView(openPicker: $openPicker, photos: $provider.photos, selected: $selected)
            .tag(1)
            .tabItem {
                HStack {
                    Image(systemName: "photo")
                    Text("All photos")
                }
            }
        return view
    }
    
    var albumsView: some View {
        let view = AlbumsView(albums: $provider.albums)
            .tag(2)
            .tabItem {
                HStack {
                    Image(systemName: "folder")
                    Text("Almubs")
                }
            }
        return view
    }
}

struct AssetPicker_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            Rectangle()
                .tabItem {
                    HStack {
                        Image(systemName: "photo")
                        Text("All photos")
                    }
                }
            Rectangle()
                .tabItem {
                    HStack {
                        Image(systemName: "folder")
                        Text("Almubs")
                    }
                }
        }
    }
}
