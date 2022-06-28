//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import SwiftUI
import Chat

struct SimpleExampleView: View {
    @StateObject var viewModel = SimpleExampleViewModel()

    var body: some View {
        ChatView(messages: $viewModel.messages) { draft in
            viewModel.send(draft: draft)
        }
        .chatEnablePagination(offset: 3) { message in
            viewModel.loadMoreMessage(before: message)
        }
        .chatMessageUseMarkdown()
        .onAppear {
            viewModel.onStart()
        }
        .onDisappear {
            viewModel.onStop()
        }
        .navigationTitle("Simple example")
        .navigationBarTitleDisplayMode(.inline)
    }
}
