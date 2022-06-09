//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI

public struct AssetsPicker: View {
    @Binding public var openPicker: Bool
    public let completion: AssetsPickerCompletionClosure

    @StateObject private var viewModel = AssetsPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var permissionService = PermissionsService()
    
    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
    // MARK: - Object life cycle
    public init(openPicker: Binding<Bool>, completion: @escaping AssetsPickerCompletionClosure) {
        self._openPicker = openPicker
        self.completion = completion
    }
    
    // MARK: - SwiftUI View implementation
    public var body: some View {
        NavigationView {
            VStack {
                switch viewModel.mode {
                case .photos:
                    AlbumView(
                        isSent: $viewModel.isSent,
                        shouldShowCamera: true,
                        isShowCamera: $viewModel.showCamera,
                        viewModel: AlbumViewModel(
                            mediasProvider: AllPhotosProvider()
                        )
                    )
                case .albums:
                    AlbumsView(
                        isSent: $viewModel.isSent,
                        isShowCamera: $viewModel.showCamera,
                        viewModel: AlbumsViewModel(
                            albumsProvider: DefaultAlbumsProvider()
                        )
                    )
                }
            }
            .assetsPickerNavigationBar(mode: $viewModel.mode) {
                openPicker = false
            }
        }
        .navigationViewStyle(.stack)
        .environmentObject(selectionService)
        .environmentObject(permissionService)
        .onAppear {
            selectionService.assetSelectionLimit = assetSelectionLimit
        }
        .cameraSheet(isShow: $viewModel.showCamera, image: $viewModel.cameraImage)
        .onChange(of: viewModel.isSent) { flag in
            guard flag else {
                return
            }
            openPicker = false
            completion(selectionService.mapToMedia())
        }
#if os(iOS)
        .onChange(of: viewModel.cameraImage) { newValue in
            guard let url = newValue
            else {
                return
            }
            openPicker = false
            completion([Media(source: .url(url), type: .image)])
        }
#endif
    }
}
