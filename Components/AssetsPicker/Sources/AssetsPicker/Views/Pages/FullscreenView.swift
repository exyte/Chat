//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 06.06.2022.
//

import SwiftUI
import Combine
import AVKit

struct FullscreenContainer: View {
    var medias: [MediaModel]
    @State var index: Int
    @Binding var selected: [MediaModel]
    
    @Environment(\.assetSelectionLimit) private var assetSelectionLimit
    
    var body: some View {
        TabView(selection: $index) {
            ForEach(medias.enumerated().map({ $0 }), id: \.offset) { (index, media) in
                let selected = selected.firstIndex(of: media)
                SelectableView(selected: selected) {
                    toggleSelection(for: media)
                } content: {
                    FullscreenView(viewModel: FullscreenViewModel(media: media))
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.black)
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

@MainActor
final class FullscreenViewModel: ObservableObject {
    let media: MediaModel
    
    @Published var preview: UIImage? = nil
    @Published var player: AVPlayer? = nil
    var bag = Set<AnyCancellable>()
    
    init(media: MediaModel) {
        self.media = media
        onStart()
    }
    
    func onStart() {
        switch media.mediaType {
        case .image:
            fetchImage()
        case .video:
            Task {
                await fetchVideo()
            }
        default:
            break
        }
    }
    
    private func fetchImage() {
        let size = CGSize(width: media.source.pixelWidth, height: media.source.pixelHeight)
        AssetUtils
            .image(from: media.source, size: size)
            .print("AssetUtils.image")
            .sink { [weak self] in
                self?.preview = $0
            }
            .store(in: &bag)
    }
    
    private func fetchVideo() async {
        let url = await media.source.getURL()
        guard let url = url else {
            return
        }
        player = AVPlayer(url: url)
    }
}

struct FullscreenView: View {
    @StateObject var viewModel: FullscreenViewModel
    
    var body: some View {
        if let preview = viewModel.preview {
            Image(uiImage: preview)
                .resizable()
                .scaledToFit()
        } else if let player = viewModel.player {
            VideoPlayer(player: player)
                .padding()
        } else {
            ProgressView()
        }
    }
}
