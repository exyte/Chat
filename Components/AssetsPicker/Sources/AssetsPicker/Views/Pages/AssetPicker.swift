//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import UIKit

enum AssetPickerMode: Int, CaseIterable, Identifiable {
    case photos = 1
    case albums = 2
    
    var id: Int { self.rawValue }
    
    var name: String {
        switch self {
        case .photos:
            return "Photos"
        case .albums:
            return "Albums"
        }
    }
}

public struct AssetPicker: View {
    @Binding public var openPicker: Bool
    
    @StateObject var provider = PhotoProviderService()
    
    @State private var mode: AssetPickerMode = .photos
    
    public init(openPicker: Binding<Bool>) {
        self._openPicker = openPicker
    }
    
    public var body: some View {
        NavigationView {
            Group {
                switch mode {
                case .photos:
                    AlbumView(
                        assets: provider.photos,
                        selected: $provider.selectedAssetIds
                    )
                case .albums:
                    AlbumsView(
                        albums: provider.albums,
                        selected: $provider.selectedAssetIds
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $mode) {
                        ForEach(AssetPickerMode.allCases) { mode in
                            Text(mode.name).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") { openPicker = false }
            )
        }
        .onAppear {
            Task {
                await provider.fetchAllPhotos()
                await provider.fetchAlbums()
            }
        }
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
