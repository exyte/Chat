//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import Chat

struct ExampleView: View {
    @ObservedObject var viewModel: AbstractExampleViewModel

    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.send(draft: draft)
        }
        .chatMessageUseMarkdown()
        .onAppear {
            viewModel.onStart()
        }
    }
}
