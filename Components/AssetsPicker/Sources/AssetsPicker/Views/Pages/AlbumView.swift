//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {
    let title: String?
    let onTapCamera: (() -> Void)?
    let medias: [MediaModel]
    let isLoading: Bool
    @Binding var selected: [MediaModel]
    @Binding var isSent: Bool
    var assetsAction: AssetsLibraryAction?
    var cameraAction: CameraAction?
    
    @State private var fullscreenItem: MediaModel?
    @Namespace private var assetNamespace
    
    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
    var body: some View {
//        ZStack {
            if let title = title {
                content.navigationTitle(title)
            } else {
                content
            }
            
//            if let item = fullscreenItem {
//                FullscreenView(model: item, assetNamespace: assetNamespace)
//                    .onTapGesture {
//                        withAnimation {
//                            fullscreenItem = nil
//                        }
//                    }
//            }
//        }
    }
}

private extension AlbumView {
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0)]
    }
    
    @ViewBuilder
    var content: some View {
            ScrollView {
                VStack {
                    if let action = assetsAction {
                        PermissionsActionView(action: .library(action))
                    }
                    if onTapCamera != nil, let action = cameraAction {
                        PermissionsActionView(action: .camera(action))
                    }
                    if isLoading {
                        ProgressView()
                    } else if medias.isEmpty {
                        Text("Empty data")
                            .font(.title3)
                    } else {
                        AssetsGrid(medias) {
                            if cameraAction == nil, let onTapCamera = onTapCamera {
                                CameraCell(action: onTapCamera)
                            } else {
                                EmptyView()
                            }
                        } content: { media in
                            let index = selected.firstIndex(of: media)
                            Button {
                                withAnimation {
                                    fullscreenItem = media
                                }
                            } label: {
                                SelectableView(selected: index) {
                                    toggleSelection(for: media)
                                } content: {
                                    MediaCell(viewModel: MediaViewModel(media: media))
                                }
                                .disabled(selected.count >= assetSelectionLimit && index == nil)
                            }
                            .padding(2)
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
            .sheet(item: $fullscreenItem) { item in
                FullscreenContainer(
                    medias: medias,
                    index: medias.firstIndex(of: item) ?? 0,
                    selected: $selected
                )
            }
    }
    
    func toggleSelection(for asset: MediaModel) {
        if let index = selected.firstIndex(of: asset) {
            selected.remove(at: index)
        } else {
            if selected.count < assetSelectionLimit {
                selected.append(asset)
            }
        }
    }
}
