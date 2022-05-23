//
//  ChatView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import Introspect

struct ChatView: View {

    var messages: [Message]

    var didSendMessage: (Message)->()

    @State private var text: String = ""
    @State private var textSize: CGRect = .zero
    @State private var scrollView: UIScrollView?

    @State private var showingImageModePicker = false
    @State private var selectedImageMode: UIImagePickerController.SourceType = .camera

    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.id) { message in
                    MessageView(message: message)
                }
                .listRowSeparator(.hidden)
            }
            .introspectScrollView { scrollView in
                self.scrollView = scrollView
            }

            HStack {
                Button("Pick") {
                    showingImageModePicker = true
                }
                textView()
                Button("Send") {
                    let m = Message(id: Int.random(in: 10...10000), text: text)
                    didSendMessage(m)
                    text = ""
                    scrollToBottom()
                }
            }
            .padding(5)
            .background(Color(hex: "EEEEEE"))
        }
        .onChange(of: messages) { _ in
            scrollToBottom()
        }
        .actionSheet(isPresented: $showingImageModePicker) {
            ActionSheet(
                title: Text(""),
                message: .none,
                buttons: [
                    .default(Text("Camera")) {
                        selectedImageMode = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Gallery")) {
                        selectedImageMode = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .fullScreenCover(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: selectedImageMode, image: $selectedImage)
        }
    }

    func scrollToBottom() {
        if let scrollView = scrollView {
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height)
        }
    }

    func textView() -> some View {
        ZStack {
            Text(text)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(5)
                .frameGetter($textSize)

            TextEditor(text: $text)
                .frame(height: textSize.height)
                .frame(minHeight: 35)
                .background(Color.white)
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

struct MessageView: View {

    let myColor = Color(hex: "ADD8E6")
    let friendColor = Color(hex: "DDDDDD")

    let imageSize = 30.0

    let message: Message

    var body: some View {
        HStack(alignment: .bottom) {
            if message.isCurrentUser {
                Spacer()
                text()
                avatar()
            } else {
                avatar()
                text()
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }

    func avatar() -> some View {
        AsyncImage(url: message.avatarURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .mask {
                    Circle()
                }
        } placeholder: {
            Circle().foregroundColor(Color.gray)
                .frame(width: imageSize, height: imageSize)
        }
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    func text() -> some View {
        VStack(alignment: .leading) {
            if let text = message.text {
                Text(text)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
            }
            if !message.imagesURLs.isEmpty {

                let columns = message.imagesURLs.count > 1 ?
                [GridItem(.flexible()), GridItem(.flexible())] :
                [GridItem(.flexible())]

                LazyVGrid(columns: columns) {
                    ForEach(message.imagesURLs, id: \.self) { url in
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 15).foregroundColor(Color.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(message.isCurrentUser ? myColor : friendColor)
        )
    }
}
