//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {
    let imageSize = 30.0
    
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isCurrentUser {
                Spacer(minLength: 40)
                text()
                avatar()
            } else {
                avatar()
                text()
                Spacer(minLength: 40)
            }
        }
        .padding(.horizontal, 8)
    }
    
    func avatar() -> some View {
        AsyncImage(url: message.avatarURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .mask {
                    Circle()
                }
        } placeholder: {
            Circle().foregroundColor(Color.gray)
                .frame(width: imageSize, height: imageSize)
        }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    func text() -> some View {
        VStack(alignment: .leading) {
            if let text = message.text, !text.isEmpty {
                Text(text)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
            }

            if !message.attachments.isEmpty {
                AttachmentsGrid(attachments: message.attachments)
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(message.isCurrentUser ? Colors.myMessage : Colors.friendMessage)
        )
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(
            message: Message(
                id: 0,
                text: "Example text",
                isCurrentUser: true
            )
        )
        MessageView(
            message: Message(
                id: 0,
                text: "Example text",
                isCurrentUser: false
            )
        )
        MessageView(
            message: Message(
                id: 0,
                attachments: [
                    ImageAttachment(
                        id: UUID().uuidString,
                        thumbnail: URL(string: "https://picsum.photos/200/300")!,
                        full: URL(string: "https://picsum.photos/200/300")!,
                        name: nil
                    )
                ],
                isCurrentUser: false
            )
        )
    }
}
