//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import AssetsPicker

struct Attachments: Identifiable, Equatable {
    let id = UUID()
    let medias: [Media]
}

struct InputView: View {
    @Binding var message: Message
    @Binding var attachments: Attachments?
    var didSendMessage: (Message) -> Void

    @State private var isOpenPicker = false
    
    @State private var selectedImage: UIImage?
    @State private var selectedImageUrl: URL?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isOpenPicker = true
                } label: {
                    Text("Pick")
                }
                TextInputView(text: $message.text)
                Button {
                    didSendMessage(message)
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
                guard !medias.isEmpty else {
                    return
                }
                attachments = Attachments(medias: medias)
            }
            .countAssetSelection()
            .assetSelectionLimit(2)
        }
    }
}

#if DEBUG
struct InputView_Previews: PreviewProvider {
    @State static private var showingImageModePicker = false
    @State static private var selectedImage: UIImage?
    @State static private var attachments: Attachments?

    @State static private var message = Message(id: 0)
    
    static var previews: some View {
        InputView(message: $message, attachments: $attachments) { message in
            debugPrint(message)
        }
    }
}
#endif
