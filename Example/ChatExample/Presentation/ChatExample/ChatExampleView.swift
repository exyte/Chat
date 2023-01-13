//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import SwiftUI
import Chat

struct ChatExampleView: View {
    @StateObject private var viewModel: ChatExampleViewModel
    
    private let title: String

    init(viewModel: ChatExampleViewModel = ChatExampleViewModel(), title: String) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.title = title
    }
    
    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.send(draft: draft)
        }
        .chatEnablePagination(offset: 3) { message in
            viewModel.loadMoreMessage(before: message)
        }
        .chatMessageUseMarkdown()
        .chatNavigation(
            title: viewModel.chatTitle,
            status: viewModel.chatStatus,
            cover: viewModel.chatCover
        )
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }
}
