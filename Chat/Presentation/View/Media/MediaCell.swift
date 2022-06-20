//
//  MediaCell.swift
//  Chat
//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI
import Combine
import AssetsPicker

struct MediaCell: View {
    @StateObject var viewModel: MediaCellViewModel

    var body: some View {
        content
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.delete()
                } label: {
                    Image(systemName: "trash")
                        .padding(8)
                        .background(.red)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .padding(6)
            }
            .overlay {
                if viewModel.showVideoOverlay {
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background {
                            Circle()
                                .fill(.black)
                                .opacity(0.72)
                        }
                }
            }
            .overlay {
                if viewModel.showProgress {
                    ProgressView()
                        .tint(.white)
                }
            }
            .onAppear {
                viewModel.onStart()
            }
            .onDisappear {
                viewModel.onStop()
            }
    }

    @ViewBuilder
    var content: some View {
        if let image = viewModel.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipped()
        } else {
            Rectangle()
                .fill(Color.black.opacity(0.33))
                .aspectRatio(1, contentMode: .fill)
        }
    }
}

#if DEBUG
struct MediaCell_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            MediaCell(viewModel: MediaCellViewModel(media: .random, onDelete: {}))
            MediaCell(viewModel: MediaCellViewModel(media: .random, onDelete: {}))
            Spacer()
        }
    }
}
#endif
