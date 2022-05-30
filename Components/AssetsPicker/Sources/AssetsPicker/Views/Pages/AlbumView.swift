//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {
    let title: String?
    let onTapCamera: (() -> Void)?
    let assets: [Asset]
    @Binding var selected: [Asset]
    @Binding var isSended: Bool
    
    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
    init(title: String? = nil,
         onTapCamera: (() -> Void)? = nil,
         assets: [Asset],
         selected: Binding<[Asset]>,
         isSended: Binding<Bool>) {
        self.title = title
        self.onTapCamera = onTapCamera
        self.assets = assets
        self._selected = selected
        self._isSended = isSended
    }
    
    var body: some View {
        if let title = title {
            content
                .navigationTitle(title)
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
                if assets.isEmpty {
                    ProgressView()
                } else {
                    LazyVGrid(columns: columns, spacing: 0) {
                        if let onTapCamera  = onTapCamera {
                            Button {
                                onTapCamera()
                            } label: {
                                Rectangle()
                                    .fill(.black)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .overlay(
                                        Image(systemName: "camera")
                                            .foregroundColor(.white))
                            }
                        }
                        
                        ForEach(assets) { asset in
                            let index = selected.firstIndex(of: asset)
                            SelectableView(selected: index) {
                                toggleSelection(for: asset)
                            } content: {
                                AssetThumbnailView(asset: asset)
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
                isSended = true
            }
                .disabled(selected.isEmpty)
        )
    }
    
    func toggleSelection(for asset: Asset) {
        if let index = selected.firstIndex(of: asset) {
            selected.remove(at: index)
        } else {
            if selected.count < assetSelectionLimit {
                selected.append(asset)
            }
        }
    }
}
