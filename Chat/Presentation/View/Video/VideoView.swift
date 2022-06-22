//
//  Created by Alex.M on 21.06.2022.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @StateObject var viewModel: VideoViewModel
    @EnvironmentObject var attachmentsPagesViewModel: AttachmentsPagesViewModel

    var body: some View {
        Group {
            if let player = viewModel.player {
                content(for: player)
            } else {
                ProgressView()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.showActions()
        }
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
        .onChange(of: viewModel.hideAction) { hideActions in
            attachmentsPagesViewModel.showMinis = !hideActions
        }
    }

    func content(for player: AVPlayer) -> some View {
        Group {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VideoPlayer(player: player)
                        .allowsHitTesting(false)
                }
                .overlay {
                    if !viewModel.hideAction {
                        Button {
                            viewModel.togglePlay()
                        } label: {
                            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                        }
                    } else {
                        EmptyView()
                    }
                }
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    private static var attachment = VideoAttachment(
        thumbnail: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg")!,
        full: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    )

    static var previews: some View {
        VideoView(
            viewModel: VideoViewModel(attachment: attachment)
        )
    }
}
