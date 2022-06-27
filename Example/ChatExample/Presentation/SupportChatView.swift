//
//  Created by Alex.M on 24.06.2022.
//

import SwiftUI
import Chat

final class SupportChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

//    private var supportService = SupportChatService()

    func send(message: DraftMessage) {
//        supportService.send(message: message.text)
    }

    func onStart() {
//        supportService.messages
//            .compactMap { [weak self] in
//                self?.mapMessages($0)
//            }
//            .assign(to: &$messages)
    }

//    private func mapMessages(_ messages: [SupportChatMessage]) -> [Chat.Message] {
//        messages.map {
//            Message(
//                id: .random(in: 1..<Int.max),
//                user: User(
//                    avatarURL: nil,
//                    isCurrentUser: ($0.sender == .user)
//                ),
//                text: $0.message,
//                createdAt: $0.createdAt
//            )
//        }
//    }
}

struct SupportChatView: View {
    @StateObject var viewModel = SupportChatViewModel()

    var body: some View {
        ChatView(messages: viewModel.messages) { draft in
            viewModel.send(message: draft)
        }
        .chatMessageUseMarkdown()
        .onAppear {
            viewModel.onStart()
        }
    }
}

struct SupportChatView_Previews: PreviewProvider {
    static var previews: some View {
        SupportChatView()
    }
}
