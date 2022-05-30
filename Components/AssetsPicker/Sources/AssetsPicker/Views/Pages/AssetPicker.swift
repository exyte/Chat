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
    // MARK: - Types
    public typealias SelectClosure = ([Asset]) -> Void
    
    // MARK: - Initial values
    @Binding public var openPicker: Bool
    let onSelect: SelectClosure
    
    // MARK: - Public immutable values
    
    // MARK: - Private values
    @StateObject var provider = AssetsService()
    @State private var mode: AssetPickerMode = .photos
    @State private var isSended = false

    // MARK: - Object life cycle
    public init(openPicker: Binding<Bool>, onSelect: @escaping SelectClosure) {
        self._openPicker = openPicker
        self.onSelect = onSelect
    }

    // MARK: - SwiftUI View implementation
    public var body: some View {
        NavigationView {
            Group {
                switch mode {
                case .photos:
                    AlbumView(
                        onTapCamera: {
                            debugPrint("Open camera")
                        },
                        assets: provider.photos,
                        selected: $provider.selectedAssets,
                        isSended: $isSended
                    )
                case .albums:
                    AlbumsView(
                        albums: provider.albums,
                        selected: $provider.selectedAssets,
                        isSended: $isSended
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
        .onChange(of: isSended) { flag in
            guard flag else { return }
            openPicker = false
            onSelect(provider.selectedAssets)
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
