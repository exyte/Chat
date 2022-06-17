//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

struct ExampleView: View {
    @State var messages: [Message] = []

    var body: some View {
        ChatView(messages: messages) { draft in
            let message = Message(
                id: messages.count + 1,
                author: .tim,
                text: draft.text,
                attachments: draft.attachments,
                createdAt: draft.createAt
            )
            messages.append(message)
        }
        .onAppear {
            messages =
            [
                Message(id: 1, author: .tim, text: "Hey"),
                Message(id: 2, author: .steve, text: "Yeah sure, gimme 5"),
                Message(id: 3, author: .steve, text: "Okay ready when you are"),
                Message(id: 4, author: .tim, text: "Awesome 😁"),
                Message(id: 5, author: .tim, text: "Ugh, gotta sit through these two"),
                Message(id: 6, author: .steve, text: "Every. Single. Time. Every. Single. Time. Every. Single. Time. Every. Single. Time."),
                Message(
                    id: 7,
                    author: .steve,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ]),
                Message(
                    id: 8,
                    author: .steve,
                    text: "Hey",
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ]),
                Message(
                    id: 9,
                    author: .steve,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!),
                    ]),
                Message(
                    id: 10,
                    author: .tim,
                    attachments: [
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!)
                    ]),
                Message(
                    id: 11,
                    author: .tim,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                    ]),
            ]
        }
    }
}

extension Author {
    static let tim = Author(
        avatarURL: URL(string: "https://placeimg.com/640/480/animal"),
        isCurrentUser: true
    )
    static let steve = Author(
        avatarURL: URL(string: "https://placeimg.com/640/480/arch"),
        isCurrentUser: false
    )
}
