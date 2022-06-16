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
    @Binding var isShown: Bool
    @StateObject var viewModel: AttachmentsViewModel
    
    @State var imagesHeight: CGFloat = 80

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
                        self.isShown = false
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
                    ForEach(viewModel.attachments) { media in
                        MediaCell(media: media) {
                            withAnimation {
                                viewModel.delete(media)
                            }
                        }
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            imagesHeight = proxy.size.height
                        }
                    }
                )
            }
            .frame(maxHeight: imagesHeight)

            TextInputView(text: $viewModel.message.text)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .background(Colors.background)
        .onChange(of: viewModel.isShown) { newValue in
            guard !newValue else { return }
            withAnimation {
                self.isShown = false
            }
        }
    }
}

#if DEBUG
struct AttachmentsView_Previews: PreviewProvider {
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
                    isShown: .constant(true),
                    viewModel: AttachmentsViewModel(
                        attachments: [.random, .random, .random, .random, .random, .random],
                        onSend: { _ in }
                    )
                )
                .cornerRadius(20)
                .padding(.horizontal, 20)
            }
    }
}
#endif
