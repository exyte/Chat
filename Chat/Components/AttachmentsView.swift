//
//  AttachmentsView.swift
//  Chat
//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI
import AssetsPicker

struct AttachmentsView: View {
    @Binding var isShown: Bool

    let attachments: Attachments
    let currentMessage: String?

    var onSend: (Message) -> Void

    @State var message = Message(id: 0)
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
                    sendMessage()
                }
            }
            .padding(.bottom)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(attachments.medias) { media in
                        MediaCell(media: media)
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

            TextInputView(text: $message.text)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .background(Color(hex: "EEEEEE"))
        .onAppear {
            message.text = currentMessage ?? ""
        }
    }
}

private extension AttachmentsView {
    func sendMessage() {
        Task { [attachments] in
            var images: [URL] = []
            var videos: [URL] = []

            for item in attachments.medias {
                let url = await item.getUrl().value
                if let url = url {
                    switch item.type {
                    case .image:
                        images.append(url)
                    case .video:
                        videos.append(url)
                    }
                }
            }
            self.message.imagesURLs = images
            self.message.videosURLs = videos

            DispatchQueue.main.async { [message] in
                self.isShown = false
                onSend(message)
                self.message = Message(id: 0)
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
                    attachments: Attachments(medias: [.random, .random, .random, .random, .random, .random]),
                    currentMessage: nil,
                    onSend: { _ in }
                )
                .cornerRadius(20)
                .padding(.horizontal, 20)
            }
    }
}
#endif
