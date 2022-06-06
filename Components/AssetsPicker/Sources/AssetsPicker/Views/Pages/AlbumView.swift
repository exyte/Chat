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

    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
    var body: some View {
        if let title = title {
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
    
    var content: some View {
        ScrollView {
            VStack {
                if let assetsAction = assetsAction {
                    AssetsLibraryActionView(action: assetsAction)
                }
                
                if cameraAction != nil {
                    Button {
                        guard let url = URL(string: UIApplication.openSettingsURLString)
                        else { return }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Need camera permission")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(5)
                    .padding(.horizontal, 20)
                }
                if isLoading {
                    ProgressView()
                } else if medias.isEmpty {
                    Text("Empty data")
                        .font(.title3)
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        if cameraAction == nil, let onTapCamera = onTapCamera {
                            Button {
                                onTapCamera()
                            } label: {
                                Rectangle().fill(.black)
                                           .aspectRatio(1.0, contentMode: .fit)
                                           .overlay(
                                               Image(systemName: "camera")
                                               .foregroundColor(.white))
                            }
                        }
                        
                        ForEach(medias) { media in
                            let index = selected.firstIndex(of: media)
                            SelectableView(selected: index) {
                                toggleSelection(for: media)
                            } content: {
                                MediaCell(
                                    viewModel: MediaViewModel(media: media)
                                )
                            }
                            .padding(2)
                            .disabled(selected.count >= assetSelectionLimit && index == nil)
                        }
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
