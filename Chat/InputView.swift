//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import AssetsPicker

struct InputView: View {
    var didSendMessage: (Message) -> Void
    
    @State private var message: Message = Message(id: 0)
    @State private var mediasForSend: [Media]?
    
    @State private var textSize: CGRect = .zero
    @State private var isOpenPicker = false
    
    @State private var selectedImage: UIImage?
    @State private var selectedImageUrl: URL?
    
    var body: some View {
        VStack {
            if let mediasForSend = mediasForSend {
                MediaSendPreview(medias: mediasForSend)
            }

            HStack {
                Button {
                    isOpenPicker = true
                } label: {
                    Text("Pick")
                }
                textView()
                Button {
                    didSendMessage(message)
                    message = Message(id: 0)
                } label: {
                    Text("Send")
                }
            }
            .padding(5)
        }
        .background(Color(hex: "EEEEEE"))
        .sheet(isPresented: $isOpenPicker) {
            AssetsPicker(openPicker: $isOpenPicker) { medias in
                // FIXME: AssetPicker shouldn't return empty array
                mediasForSend = medias.isEmpty ? nil : medias
            }
            .countAssetSelection()
            .assetSelectionLimit(2)
        }
    }
}

private extension InputView {
    func textView() -> some View {
        ZStack {
            Text(message.text)
                .font(.system(.body))
                .padding(5)
                .frameGetter($textSize)
                .hidden()
            
            VStack {
                TextEditor(text: $message.text)
                    .frame(minHeight: 35)
                    .frame(height: textSize.height)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 10)
                            .foregroundColor(.white)
                    )
                    .padding(8)
            }
        }
    }
    
    func mapMediasToMessage() {
        guard let medias = mediasForSend
        else { return }
        
        Task { [medias] in
            var images: [URL] = []
            var videos: [URL] = []

            for item in medias {
                let url = await item.getUrl()
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
        }
    }
}

struct InputView_Previews: PreviewProvider {
    @State static private var showingImageModePicker = false
    @State static private var selectedImage: UIImage?
    
    static var previews: some View {
        InputView { message in
            debugPrint(message)
        }
    }
}
