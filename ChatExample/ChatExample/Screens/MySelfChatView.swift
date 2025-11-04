//
//  MySelfChatView.swift
//  Notica-Smart-AI-Note
//
//  Created by ThanPD on 19/6/25.
//

import SwiftUI

struct MySelfChatView: View {
//    @ObservedObject var message: ChatMessage
    
    var copyAction: (() -> Void)?
    var shareAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            contentView
//                .disabled(message.isGenerating)
            
//            if message.isFailedToSend {
                failToSendView
                    .padding(.top, 4)
//            }
        }
        .padding(.horizontal, 16)
    }
    
    var contentView: some View {
        HStack(alignment: .top, spacing: 8) {
            Spacer()
                .frame(width: 40)
            
            Text("hello what the hell")
                .contextMenu {
                    Button {
    //                    viewWithMenuViewModel.copiedToClipboard(text: message.content)
                        copyAction?()
                    } label: {
                        Text("Copy")
                            .font(.largeTitle)

    //                    Image(uiImage: R.image.ic_copied()!)
    //                        .resizable()
    //                        .scaledToFit()
    //                        .frame(width: 24, height: 24)
                    }
                    
                    Button {
                        shareAction?()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        deleteAction?()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            
//            ViewWithMenu(
//                message: "Hello, My name is John",
//                copyAction: copyAction,
//                shareAction: shareAction,
//                deleteAction: deleteAction,
//                content: {
//                    Text("Hello, My name is John")
////                        .setTextDefaultColor(
////                            color: .white,
////                            fontStyle: R.font.plusJakartaSansMedium(size: iPad ? 22 : 16)
////                        )
//                        .lineSpacing(4)
//                        .multilineTextAlignment(.leading)
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 9)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            )
        }
    }

    var failToSendView: some View {
        HStack(spacing: 4) {
            Spacer()
            
            Image("ic_warning_failed")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Button {
                retryAction?()
            } label: {
                Text("Failed to send. Tap to retry.")
//                    .setTextDefaultColor(
//                        color: .systemRed,
//                        fontStyle: R.font.plusJakartaSansRegular(size: iPad ? 14 : 12)
//                    )
            }
        }
    }
}

//
//  ViewWithMenu.swift
//  Notica-Smart-AI-Note
//
//  Created by ThanPD on 19/6/25.
//

import SwiftUI

struct ViewWithMenu<Content: View>: View {
    let content: Content
    var message: String
    
    var copyAction: (() -> Void)?
    var shareAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    
    init(message: String, copyAction: (() -> Void)?, shareAction: (() -> Void)?, deleteAction: (() -> Void)?, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.message = message
        self.copyAction = copyAction
        self.shareAction = shareAction
        self.deleteAction = deleteAction
    }
    
//    @StateObject private var viewWithMenuViewModel = ViewWithMenuViewModel()
    
    var body: some View {
        content
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
            .contextMenu {
                Button {
//                    viewWithMenuViewModel.copiedToClipboard(text: message.content)
                    copyAction?()
                } label: {
                    Text("Copy")
                        .font(.largeTitle)

//                    Image(uiImage: R.image.ic_copied()!)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 24, height: 24)
                }
                
                Button {
                    shareAction?()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                    deleteAction?()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
//            .frame(maxWidth: .infinity, alignment: messageRole == .assitant ? .leading : .trailing)
    }
}
