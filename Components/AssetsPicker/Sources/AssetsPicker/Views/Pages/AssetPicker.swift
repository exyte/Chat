//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
#if os(iOS)
import UIKit.UIImage
#endif

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
    public typealias CompletionClosure = ([Media]) -> Void
    
    // MARK: - Initial values
    @Binding public var openPicker: Bool
    let completion: CompletionClosure
    
    // MARK: - Public immutable values
    
    // MARK: - Private values
    @StateObject var assetsService = AssetsService()
    @StateObject var cameraService = CameraService()

    @State private var mode: AssetPickerMode = .photos
    @State private var isSent = false
#if os(iOS)
    @State private var showCamera = false
    @State private var cameraImage: URL?
#endif

    // MARK: - Object life cycle
    public init(openPicker: Binding<Bool>, completion: @escaping CompletionClosure) {
        self._openPicker = openPicker
        self.completion = completion
    }

    // MARK: - SwiftUI View implementation
    public var body: some View {
        NavigationView {
            VStack {
                switch mode {
                case .photos:
                    AlbumView(
                        title: nil,
                        onTapCamera: {
                            showCamera = true
                        },
                        medias: assetsService.photos,
                        isLoading: assetsService.isLoading,
                        selected: $assetsService.selectedMedias,
                        isSent: $isSent,
                        assetsAction: assetsService.action,
                        cameraAction: cameraService.action
                    )
                case .albums:
                    AlbumsView(
                        albums: assetsService.albums,
                        isLoading: assetsService.isLoading,
                        selected: $assetsService.selectedMedias,
                        isSent: $isSent,
                        assetsAction: assetsService.action,
                        cameraAction: cameraService.action
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
            .navigationBarTitleDisplayMode(.inline)
        }
        
#if targetEnvironment(simulator)
        .sheet(isPresented: $showCamera) {
            CameraStubView(isShow: $showCamera)
        }
#elseif os(iOS)
        .sheet(isPresented: $showCamera) {
            CameraView(url: $cameraImage, isShown: $showCamera)
        }
#endif
        .onChange(of: isSent) { flag in
            guard flag else { return }
            openPicker = false
            completion(assetsService.pickedMedias)
        }
#if os(iOS)
        .onChange(of: cameraImage) { newValue in
            guard let url = newValue
            else { return }
            openPicker = false
            completion([Media(source: .url(url), type: .image)])
        }
#endif
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
                        Text("Albums")
                    }
                }
        }
    }
}
