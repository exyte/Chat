//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import SwiftUI
import AVKit

struct FullscreenCell: View {
    @StateObject var viewModel: FullscreenCellViewModel
    
    var body: some View {
        VStack {
            if let preview = viewModel.preview {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
            } else if let player = viewModel.player {
                VideoPlayer(player: player)
                    .padding()
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
    }
}
