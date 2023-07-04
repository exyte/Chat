//
//  AuthView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI

struct AuthView: View {

    @StateObject var viewModel = AuthViewModel()

    @State var name: String = ""

    var body: some View {
        VStack {
            Text("Welcome!")
            Text("Create a test account")

            TextField("Nickname", text: $name)
                .border(Color.gray, width: 1)
            Button("Let me in") {
                viewModel.auth(nickname: name)
            }
            .buttonStyle(.borderedProminent)

            Color.clear.frame(height: 50)

            Text("You can skip this step and the app will randomize your profile")
            Button("Randomize") {
                viewModel.auth(nickname: randomString(length: 8))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(15)
    }
}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
