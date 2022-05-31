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
    
    @State private var textSize: CGRect = .zero
    @State private var isOpenPicker = false
    
    @State private var selectedImage: UIImage?
    @State private var selectedImageUrl: URL?
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(message.imagesURLs, id: \.self) { url in
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 70)
                        } placeholder: {
                            Text("Loading")
                        }
                        .frame(maxHeight: 70)
                        .padding()
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(4.0)
                                .background(.gray.opacity(0.6))
                                .onTapGesture {
                                    message.imagesURLs.removeAll { $0 == url }
                                }
                        }
                    }
                }
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
            AssetPicker(openPicker: $isOpenPicker) { items in
                debugPrint(items)
                Task {
                    var urls: [URL] = []
                    for item in items {
                        let url = await item.getUrl()
                        if let url = url {
                            urls.append(url)
                        }
                    }
                    // FIXME: Separate images/videos or create identifier for media type
                    self.message.imagesURLs = urls
                }
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
