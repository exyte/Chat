//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

final class MessageViewModel: ObservableObject {
    var parser: any MessageParser = DefaultMessageParser()

    func text(from message: String) -> Text {
        parser.text(from: message)
    }
}

struct MessageView: View {
    @ObservedObject var viewModel: MessageViewModel
    let message: Message

    @Environment(\.messageParser) var messageParser

    var body: some View {
        MessageContainer(author: message.author) {
            VStack(alignment: .leading) {
                if !message.text.isEmpty {
                    messageParser.text(from: message.text)
//                    viewModel.text(from: message.text)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                }

                if !message.attachments.isEmpty {
                    AttachmentsGrid(attachments: message.attachments)
                }
            }
        }
//        .onAppear {
//            viewModel .
//        }
    }
}

struct MessageView_Previews: PreviewProvider {
    @StateObject static var markdownMessageViewModel: MessageViewModel = MessageViewModel()
    @StateObject static var defaultMessageViewModel: MessageViewModel = MessageViewModel()

    static var previews: some View {
        MessageView(
            viewModel: defaultMessageViewModel,
            message: Message(
                id: 0,
                author: .tim,
                text: "Example text"
            )
        )
        MessageView(
            viewModel: markdownMessageViewModel,
            message: Message(
                id: 0,
                author: .steve,
                text: "*Example* **markdown** _text_"
            )
        )
        MessageView(
            viewModel: defaultMessageViewModel,
            message: Message(
                id: 0,
                author: .steve,
                attachments: [
                    ImageAttachment(
                        id: UUID().uuidString,
                        thumbnail: URL(string: "https://picsum.photos/200/300")!,
                        full: URL(string: "https://picsum.photos/200/300")!,
                        name: nil
                    )
                ]
            )
        )
    }
}
