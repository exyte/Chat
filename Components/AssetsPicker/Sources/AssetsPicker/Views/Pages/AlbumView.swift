//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {
    let title: String?
    let onTapCamera: (() -> Void)?
    let medias: [MediaModel]
    @Binding var selected: [MediaModel]
    @Binding var isSent: Bool
    @Binding var action: AssetsLibraryAction?
    
    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
//    init(title: String? = nil,
//         onTapCamera: (() -> Void)? = nil,
//         medias: [MediaModel],
//         selected: Binding<[MediaModel]>,
//         isSent: Binding<Bool>) {
//        self.title = title
//        self.onTapCamera = onTapCamera
//        self.medias = medias
//        self._selected = selected
//        self._isSent = isSent
//    }
    
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
                if let action = action {
                    AssetsLibraryActionView(action: action)
                }
                if medias.isEmpty {
                    ProgressView()
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        if let onTapCamera = onTapCamera {
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
                                MediaCell(media: media)
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
