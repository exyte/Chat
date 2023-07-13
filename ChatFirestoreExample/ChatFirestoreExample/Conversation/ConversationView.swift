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
        .mediaPickerTheme(
            main: .init(
                text: .white,
                albumSelectionBackground: .examplePickerBg,
                fullscreenPhotoBackground: .examplePickerBg
            ),
            selection: .init(
                emptyTint: .white,
                emptyBackground: .black.opacity(0.25),
                selectedTint: .exampleBlue,
                fullscreenTint: .white
            )
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    if let conversation = viewModel.conversation {
                        AvatarView(url: conversation.pictureURL, size: 44)
                        Text(conversation.title)
                    } else if let user = viewModel.users.first {
                        AvatarView(url: user.avatarURL, size: 44)
                        Text(user.name)
                    }
                }
            }
        }
    }
}
