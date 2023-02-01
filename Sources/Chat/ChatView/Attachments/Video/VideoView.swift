//
//  Created by Alex.M on 21.06.2022.
//

import SwiftUI
import AVKit

struct VideoView: View {

    @EnvironmentObject var attachmentsPagesViewModel: AttachmentsPagesViewModel
    @Environment(\.chatTheme) private var theme

    @StateObject var viewModel: VideoViewModel

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
                            (viewModel.isPlaying ? theme.images.pauseCircleButton : theme.images.playCircleButton)
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                        }
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
