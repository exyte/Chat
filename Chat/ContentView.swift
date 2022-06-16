//
//  ContentView.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

struct ContentView: View {

    let timAvatar = URL(string: "https://placeimg.com/640/480/animal")
    let steveAvatar = URL(string: "https://placeimg.com/640/480/arch")

    @State var messages: [Message] = []

    var body: some View {
        ChatView(messages: messages) { message in
            var message = message
            message.isCurrentUser = true
            message.id = messages.count + 1
            messages.append(message)
        }
        .onAppear {
            messages =
            [
                Message(id: 1, text: "Hey", avatarURL: timAvatar, isCurrentUser: true),
                Message(id: 2, text: "Yeah sure, gimme 5", avatarURL: steveAvatar),
                Message(id: 3, text: "Okay ready when you are", avatarURL: steveAvatar),
                Message(id: 4, text: "Awesome 😁", avatarURL: timAvatar, isCurrentUser: true),
                Message(id: 5, text: "Ugh, gotta sit through these two", avatarURL: timAvatar, isCurrentUser: true),
                Message(id: 6, text: "Every. Single. Time. Every. Single. Time. Every. Single. Time. Every. Single. Time.", avatarURL: steveAvatar),
                Message(
                    id: 7,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ],
                    avatarURL: steveAvatar),
                Message(
                    id: 8,
                    text: "Hey",
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
                    ],
                    avatarURL: steveAvatar),
                Message(
                    id: 9,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!),
                    ],
                    avatarURL: steveAvatar
                ),
                Message(
                    id: 10,
                    attachments: [
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!)
                    ],
                    avatarURL: timAvatar,
                    isCurrentUser: true
                ),
                Message(
                    id: 11,
                    attachments: [
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                        VideoAttachment(url: URL(string: "https://placeimg.com/640/480/animal")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!),
                        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/arch")!),
                    ],
                    avatarURL: timAvatar,
                    isCurrentUser: true
                ),
            ]
        }
    }
}
