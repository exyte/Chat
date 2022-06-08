//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct MediaCell: View {
    @StateObject var viewModel: MediaViewModel
    
    var body: some View {
        ZStack {
            Group {
                ThumbnailView(preview: viewModel.preview)
                    .aspectRatio(1, contentMode: .fill)
            }
            if let duration = viewModel.media.source.formattedDuration {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top))
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                            .padding(.bottom, 4)
                    }
                }
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
