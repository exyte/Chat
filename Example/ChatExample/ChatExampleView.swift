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
//        messageBuilder: { message, _, _ in
//            Text(message.text)
//                .background(Color.green)
//                .cornerRadius(10)
//                .padding(10)
//        }
//        inputViewBuilder: { textBinding, attachments, state, style, actionClosure in
//            Group {
//                switch style {
//                case .message:
//                    VStack {
//                        HStack {
//                            Button("Send") { actionClosure(.send) }
//                            Button("Attach") { actionClosure(.photo) }
//                        }
//                        TextField("Write your message", text: textBinding)
//                    }
//                case .signature:
//                    VStack {
//                        HStack {
//                            Button("Send") { actionClosure(.send) }
//                        }
//                        TextField("Compose a signature for photo", text: textBinding)
//                            .background(Color.green)
//                    }
//                }
//            }
//        }
        .enableLoadMore(offset: 3) { message in
            viewModel.loadMoreMessage(before: message)
        }
        .messageUseMarkdown(messageUseMarkdown: true)
        .chatNavigation(
            title: viewModel.chatTitle,
            status: viewModel.chatStatus,
            cover: viewModel.chatCover
        )
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
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }
}

extension Color {
    static var exampleBlue = Color(hex: "#4962FF")
    static var examplePickerBg = Color(hex: "1F1F1F")
}
