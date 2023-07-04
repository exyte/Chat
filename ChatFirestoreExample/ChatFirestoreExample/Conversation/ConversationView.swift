//
//  ConversationView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 13.06.2023.
//

import SwiftUI
import Chat

struct ConversationView: View {

    @StateObject var viewModel: ConversationViewModel

    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.sendMessage(draft)
        }
        .task {
            viewModel.getConversation()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if viewModel.users.count == 1, let user = viewModel.users.first {
                    HStack {
                        AvatarView(url: user.avatarURL, size: 44)
                        Text(user.name)
                    }
                } else {
                    Text(viewModel.users.reduce("") { $0 + $1.name + " " }.dropLast())
                }
            }
        }
    }
}
