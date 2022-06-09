//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {
    @Binding var isSent: Bool
    var shouldShowCamera: Bool
    @Binding var isShowCamera: Bool
    @StateObject var viewModel: AlbumViewModel

    @State private var fullscreenItem: MediaModel?
    
    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService
    
    var body: some View {
        if let title = viewModel.title {
            content.navigationTitle(title)
        } else {
            content
        }
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
                if let action = permissionsService.photoLibraryAction {
                    PermissionsActionView(action: .library(action))
                }
                if shouldShowCamera, let action = permissionsService.cameraAction {
                    PermissionsActionView(action: .camera(action))
                }
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.medias.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    AssetsGrid(viewModel.medias) {
                        if shouldShowCamera && permissionsService.cameraAction == nil {
                            CameraCell {
                                isShowCamera = true
                            }
                        } else {
                            EmptyView()
                        }
                    } content: { media in
                        let index = selectionService.index(of: media)
                        Button {
                            withAnimation {
                                fullscreenItem = media
                            }
                        } label: {
                            SelectableView(selected: index) {
                                selectionService.onSelect(media: media)
                            } content: {
                                MediaCell(viewModel: MediaViewModel(media: media))
                            }
                            .disabled(!selectionService.canSelect(media: media))
                        }
                        .padding(2)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarItems(
            trailing: Button("Send") {
                isSent = true
            }
                .disabled(!selectionService.canSendSelected)
        )
        .sheet(item: $fullscreenItem) { item in
            FullscreenContainer(
                medias: viewModel.medias,
                index: viewModel.medias.firstIndex(of: item) ?? 0
            )
        }
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
