//
//  AttachmentsView.swift
//  Chat
//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI
import Combine
import AssetsPicker

struct AttachmentsView: View {
    @StateObject var viewModel: AttachmentsViewModel

    @State var size = CGSize(width: 0, height: 80)

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 80), spacing: 8, alignment: .top)
        ]
    }

    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    withAnimation {
                        viewModel.cancel()
                    }
                }
                Spacer()
                Button("Send") {
                    viewModel.onTapSendMessage()
                }
            }
            .padding(.bottom)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.medias) { media in
                        MediaCell(
                            viewModel: MediaCellViewModel(
                                media: media,
                                onDelete: {
                                    withAnimation {
                                        viewModel.delete(media)
                                    }
                                }
                            )
                        )
                    }
                }
                .watchSize($size)
            }
            .frame(maxHeight: size.height)

            TextInputView(text: $viewModel.text)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .background(Colors.background)
    }
}

#if DEBUG
struct AttachmentsView_Previews: PreviewProvider {
    private static var draftMessageService = DraftMessageService()

    static var previews: some View {
        content.previewDevice(PreviewDevice(stringLiteral: "iPhone 13 mini"))
        content.previewDevice(PreviewDevice(stringLiteral: "iPhone 13 Pro Max"))
    }

    static var content: some View {
        Rectangle()
            .fill(Color.black)
            .opacity(0.3)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                AttachmentsView(
                    viewModel: AttachmentsViewModel(
                        draftMessageService: draftMessageService
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 20)
            }
            .onAppear {
                draftMessageService.select(medias: [.random, .random, .random, .random, .random, .random])
            }
    }
}
#endif
