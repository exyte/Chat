//
//  ContentView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI
import Chat
import ExyteMediaPicker

struct Collection {
    static let users = "users"
    static let conversations = "conversations"
    static let messages = "messages"
}

public typealias User = Chat.User
public typealias Message = Chat.Message
public typealias Media = ExyteMediaPicker.Media

struct ContentView: View {

    @AppStorage(hasCurrentSessionKey) var hasCurrentSession = false

    var body: some View {
        Group {
            if hasCurrentSession {
                ConversationsView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            if hasCurrentSession {
                SessionManager.shared.loadUser()
            }
        }
    }
}
