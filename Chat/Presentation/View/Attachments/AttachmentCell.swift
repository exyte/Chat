//
//  AttachmentCell.swift
//  Chat
//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

struct AttachmentCell: View {
    let attachment: any Attachment

    var body: some View {
        Group {
            if attachment is ImageAttachment {
                content
            } else if attachment is VideoAttachment {
                content
                    .overlay {
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background {
                                Circle()
                                    .fill(.black)
                                    .opacity(0.72)
                            }
                    }
            } else {
                content
                    .overlay {
                        Text("Unknown")
                    }
            }
        }
    }

    var content: some View {
        AsyncImage(url: attachment.thumbnail) { imageView in
            imageView
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
        }
        .frame(maxHeight: 200)
    }
}
