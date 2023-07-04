//
//  AuthView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI
import ExyteMediaPicker

struct AuthView: View {

    @StateObject var viewModel = AuthViewModel()

    @State var name: String = ""
    @State var showPicker = false

    @State var avatar: Media?
    @State var avatarURL: URL?

    var body: some View {
        VStack {
            Text("Welcome!")
            Text("Create a test account")

            AsyncImage(url: avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .onTapGesture {
                showPicker = true
            }

            TextField("Nickname", text: $name)
                .border(Color.gray, width: 1)
            Button("Let me in") {
                viewModel.auth(nickname: name, avatar: avatar)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(15)
        .fullScreenCover(isPresented: $showPicker) {
            MediaPicker(isPresented: $showPicker) { media in
                avatar = media.first
                Task {
                    await avatarURL = avatar?.getURL()
                }
            }
            .mediaSelectionLimit(1)
            .mediaSelectionType(.photo)
        }
    }
}
