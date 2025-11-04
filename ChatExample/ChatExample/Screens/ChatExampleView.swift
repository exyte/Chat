//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import SwiftUI
import ExyteChat

@MainActor
struct ChatExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var viewModel: ChatExampleViewModel
    
    init(viewModel: ChatExampleViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("My name is Than")
            
            ChatView(messages: viewModel.messages, chatType: .conversation) { draft in
                viewModel.send(draft: draft)
            } messageBuilder: { message, positionInGroup, positionInMessagesSection, positionInCommentsGroup, showContextMenuClosure, messageActionClosure, showAttachmentClosure in
                MySelfChatView()
            }
            .enableLoadMore(pageSize: 3) { message in
                await MainActor.run {
                    viewModel.loadMoreMessage(before: message)
                }
            }
            .keyboardDismissMode(.interactive)
            .messageUseMarkdown(true)
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }
}
