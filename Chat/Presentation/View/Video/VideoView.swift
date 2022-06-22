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
                if viewModel.hideAction {
                    content(for: player)
                        .onTapGesture {
                            viewModel.showActions()
                        }
                } else {
                    content(for: player)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.onStart()
        }
        .onChange(of: viewModel.hideAction) { hideActions in
            attachmentsPagesViewModel.showMinis = !hideActions
        }
    }

    func content(for player: AVPlayer) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.00000001))
            .background {
                VideoPlayer(player: player)
            }
            .overlay {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay {
                if !viewModel.hideAction {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            Circle()
                                .fill(.black)
                                .opacity(0.72)
                        }
                        .onTapGesture {
                            viewModel.togglePlay()
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
