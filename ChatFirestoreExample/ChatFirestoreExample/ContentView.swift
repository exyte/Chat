//
//  ContentView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI
import Chat

typealias User = Chat.User
typealias Message = Chat.Message

struct ContentView: View {

    @AppStorage(hasCurrentSessionKey) var hasCurrentSession = false

    var body: some View {
        Group {
            if hasCurrentSession {
                UsersView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            updateUser(hasCurrentSession)
        }
        .onChange(of: hasCurrentSession) { _, hasSession in
            updateUser(hasSession)
        }
    }

    func updateUser(_ hasSession: Bool) {
        if hasCurrentSession, let data = UserDefaults.standard.data(forKey: "currentUser") {
            SessionManager.shared.currentUser = try? JSONDecoder().decode(User.self, from: data)
        } else {
            SessionManager.shared.currentUser = nil
        }
    }
}
