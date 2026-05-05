//
//  Created by Alex.M on 28.06.2022.
//

import Foundation
import SwiftUI
import ExyteChat
import ActivityIndicatorView

@MainActor
struct ChatExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel: ChatExampleViewModel
    var title: String

    @State var text = ""

    let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)
    
    var body: some View {
        ChatView(messages: viewModel.messages, chatType: .conversation) { draft in
            viewModel.send(draft: draft)
        }
        .enableLoadMoreNewerMessages(paginationHandler: PaginationHandler(triggerType: .pixels(0)) {
            await viewModel.loadNewerMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleBlue))
        })
        .enableLoadMoreOlderMessages(paginationHandler: PaginationHandler(triggerType: .pixels(0)) {
            await viewModel.loadOlderMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleGrey))
        })
        .updateTransaction($viewModel.tableTransaction)
        .scrollToMessage(viewModel.scrollToParams)
        .inputViewText($text)
        .keyboardDismissMode(.interactive)
        .showUsername(true)
        .setMediaPickerLiveCameraStyle(.prominant)
        .setRecorderSettings(recorderSettings)
        .messageReactionDelegate(viewModel)
        .swipeActions(edge: .leading, performsFirstActionWithFullSwipe: true, items: [
            SwipeAction(action: onReply, activeFor: { !$0.user.isCurrentUser }, background: .blue) {
                VStack {
                    Image(systemName: "arrowshape.turn.up.left")
                        .imageScale(.large)
                        .foregroundStyle(.white)
                        .frame(height: 30)
                    Text("Reply")
                        .foregroundStyle(.white)
                        .font(.footnote)
                }
            }
        ])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("backArrow", bundle: .current)
                        .renderingMode(.template)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    if let url = viewModel.chatCover {
                        CachedAsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                Rectangle().fill(Color(hex: "AFB3B8"))
                            }
                        }
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.chatTitle)
                                .fontWeight(.semibold)
                                .font(.headline)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Text(viewModel.chatStatus)
                                .font(.footnote)
                                .foregroundColor(Color(hex: "AFB3B8"))
                        }
                        Spacer()
                    }
                }
                .padding(.leading, 10)
            }
        }
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
        .onChange(of: text) { oldValue, newValue in
            print(newValue)
        }
    }

    var activityIndicatorView: some View {
        ActivityIndicatorView(type: .default())
            .frame(width: 30, height: 30)
            .padding(.vertical, 10)
    }

    // Swipe Action
    func onReply(message: Message, defaultActions: @escaping (Message, DefaultMessageMenuAction) -> Void) {
        print("Swipe Action - Reply: \(message)")
        // This places the message in the ChatView's InputView ready for the sender to reply
        defaultActions(message, .reply)
    }
}
