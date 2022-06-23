//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI
import Combine

struct AlbumsView: View {
    @Binding var isSent: Bool
    @Binding var isShowCamera: Bool
    @StateObject var viewModel: AlbumsViewModel

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService
    @EnvironmentObject private var configurationState: ConfigurationState

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    private var cellPadding: EdgeInsets {
        EdgeInsets(top: 2, leading: 2, bottom: 8, trailing: 2)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if let action = permissionsService.photoLibraryAction {
                    PermissionsActionView(action: .library(action))
                }
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.albums.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.albums) { album in
                            NavigationLink {
                                AlbumView(
                                    isSent: $isSent,
                                    shouldShowCamera: false,
                                    isShowCamera: $isShowCamera,
                                    viewModel: AlbumViewModel(
                                        mediasProvider: AlbumMediasProvider(
                                            album: album
                                        )
                                    )
                                )
                            } label: {
                                AlbumCell(
                                    viewModel: AlbumCellViewModel(album: album)
                                )
                                .padding(cellPadding)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationBarItems(trailing: rightNavigationItem)
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}

private extension AlbumsView {
    @ViewBuilder
    var rightNavigationItem: some View {
        if configurationState.isStandalone {
            Button("Send") {
                isSent = true
            }
            .disabled(!selectionService.canSendSelected)
        } else {
            Button("Send") { }
                .hidden()
        }
    }
}
