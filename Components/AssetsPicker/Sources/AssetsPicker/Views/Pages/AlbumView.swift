//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {
    let title: String?
    let assets: [Asset]
    @Binding var selected: [String]
    
    init(title: String? = nil, assets: [Asset], selected: Binding<[String]>) {
        self.title = title
        self.assets = assets
        self._selected = selected
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
                        ForEach(assets) { asset in
                            SelectableView(
                                selected: selected.firstIndex(of: asset.id)) {
                                    toggleSelection(for: asset.id)
                                } content: {
                                    AssetPreview(asset: asset)
                                }
                                .padding(2)
                            
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarItems(
            trailing: Button("Send") {}
                .disabled(selected.isEmpty)
        )
    }
    
    func toggleSelection(for assetId: String) {
        if let index = selected.firstIndex(of: assetId) {
            selected.remove(at: index)
        } else {
            selected.append(assetId)
        }
    }
}
