//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI

final class ConfigurationState: ObservableObject {
    @Published var isStandalone: Bool = true
}

public struct AssetsPicker: View {
    @Binding public var openPicker: Bool

    @StateObject private var viewModel = AssetsPickerViewModel()
    @StateObject private var selectionService = SelectionService()
    @StateObject private var configurationState = ConfigurationState()
    @StateObject private var permissionService = PermissionsService()
    
    @Environment(\.assetsSelectionLimit) private var assetsSelectionLimit
    @Environment(\.assetsPickerCompletion) private var assetsPickerCompletion
    @Environment(\.assetsPickerOnChange) private var assetsPickerOnChange
    
    // MARK: - Object life cycle
    public init(openPicker: Binding<Bool>) {
        self._openPicker = openPicker
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
        .environmentObject(configurationState)
        .onAppear {
            selectionService.assetSelectionLimit = assetsSelectionLimit
            selectionService.onChangeClosure = assetsPickerOnChange

            configurationState.isStandalone = assetsPickerCompletion != nil
        }
        .cameraSheet(isShow: $viewModel.showCamera, image: $viewModel.cameraImage)
        .onChange(of: viewModel.isSent) { flag in
            guard flag else {
                return
            }
            openPicker = false
            assetsPickerCompletion?(selectionService.mapToMedia())
        }
#if os(iOS)
        .onChange(of: viewModel.cameraImage) { newValue in
            guard let url = newValue
            else {
                return
            }
            openPicker = false
            assetsPickerCompletion?([Media(source: .url(url), type: .image)])
        }
#endif
    }
}
