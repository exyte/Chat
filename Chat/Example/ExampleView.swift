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
                user: .tim,
                text: draft.text,
                attachments: draft.attachments,
                createdAt: draft.createdAt
            )
            messages.append(message)
        }
        .chatMessageUseMarkdown()
        .onAppear {
            messages =
            [
                Message(id: 1, user: .tim, text: "**Hey**"),
                Message(id: 2, user: .steve, text: "Yeah sure, gimme 5"),
                Message(id: 3, user: .steve, text: "Okay ready when you are"),
                Message(id: 4, user: .tim, text: "**Awesome** 😁"),
                Message(id: 5, user: .tim, text: "Ugh, gotta sit through these two"),
                Message(id: 6, user: .steve, text: "*Every. Single. Time.* Every. Single. Time. Every. Single. Time. Every. Single. Time."),
                Message(
                    id: 7,
                    user: .steve,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ]),
                Message(
                    id: 8,
                    user: .steve,
                    text: "Hey",
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ]),
                Message(
                    id: 9,
                    user: .steve,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!),
                    ]),
                Message(
                    id: 10,
                    user: .tim,
                    attachments: [
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!)
                    ]),
                Message(
                    id: 11,
                    user: .tim,
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

extension User {
    static let tim = User(
        avatarURL: URL(string: "https://placeimg.com/640/480/animal"),
        isCurrentUser: true
    )
    static let steve = User(
        avatarURL: URL(string: "https://placeimg.com/640/480/arch"),
        isCurrentUser: false
    )
}
