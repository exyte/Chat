//
//  ActiveChatExampleView.swift
//  ChatExample
//
//  Created by Alisa Mylnikova on 08.05.2026.
//

import SwiftUI
import ExyteChat

@MainActor
struct ActiveChatExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel = ActiveChatExampleViewModel()

    let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)

    var body: some View {
        ChatView(messages: viewModel.messages, chatType: .conversation) { draft in
            viewModel.send(draft: draft)
        }
        .updateTransaction($viewModel.tableTransaction)
        .keyboardDismissMode(.interactive)
        .showUsername(true)
        .messageReactionDelegate(viewModel)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            backToolbarItem
            titleToolbarItem
        }
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }

    var backToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image("backArrow", bundle: .current)
                    .renderingMode(.template)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
    }

    var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
                Text("Group chat")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text("\(viewModel.users.count + 1) members")
                    .font(.footnote)
                    .foregroundColor(Color(hex: "AFB3B8"))
            }
        }
    }
}
