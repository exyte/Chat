//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Chat

final class SimpleExampleViewModel: AbstractExampleViewModel {
    private lazy var chatData = MockChatData()

    override func send(draft: DraftMessage) {
        let message = Message(
            id: messages.count + 1,
            user: chatData.tim.toChatUser(),
            text: draft.text,
            attachments: draft.attachments,
            createdAt: draft.createdAt
        )
        messages.append(message)
    }
    
    override func onStart() {
        messages =
        [
            Message(id: 1, user: chatData.tim.toChatUser(), text: "**Hey**"),
            Message(id: 2, user: chatData.steve.toChatUser(), text: "Yeah sure, gimme 5"),
            Message(id: 3, user: chatData.steve.toChatUser(), text: "Okay ready when you are"),
            Message(id: 4, user: chatData.tim.toChatUser(), text: "**Awesome** 😁"),
            Message(id: 5, user: chatData.tim.toChatUser(), text: "Ugh, gotta sit through these two"),
            Message(id: 6, user: chatData.steve.toChatUser(), text: "*Every. Single. Time.* Every. Single. Time. Every. Single. Time. Every. Single. Time."),
            Message(
                id: 7,
                user: chatData.steve.toChatUser(),
                attachments: [
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/92c952")!,
                        full: URL(string: "https://via.placeholder.com/600/92c952")!
                    )
                ]),
            Message(
                id: 8,
                user: chatData.steve.toChatUser(),
                text: "Hey",
                attachments: [
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/771796")!,
                        full: URL(string: "https://via.placeholder.com/600/771796")!
                    )
                ]),
            Message(
                id: 9,
                user: chatData.steve.toChatUser(),
                attachments: [
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/24f355")!,
                        full: URL(string: "https://via.placeholder.com/600/24f355")!
                    ),
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/d32776")!,
                        full: URL(string: "https://via.placeholder.com/600/d32776")!
                    ),
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/f66b97")!,
                        full: URL(string: "https://via.placeholder.com/600/f66b97")!
                    ),
                ]),
            Message(
                id: 10,
                user: chatData.tim.toChatUser(),
                attachments: [
                    VideoAttachment(
                        thumbnail: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg")!,
                        full: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
                    )
                ]),
            Message(
                id: 11,
                user: chatData.tim.toChatUser(),
                attachments: [
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/56a8c2")!,
                        full: URL(string: "https://via.placeholder.com/600/56a8c2")!
                    ),
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/54176f")!,
                        full: URL(string: "https://via.placeholder.com/600/54176f")!
                    ),
                    ImageAttachment(
                        thumbnail: URL(string: "https://via.placeholder.com/150/197d29")!,
                        full: URL(string: "https://via.placeholder.com/600/197d29")!
                    ),
                ]),
        ]
    }
}
