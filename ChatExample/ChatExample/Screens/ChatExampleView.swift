//
//  Created by Alex.M on 28.06.2022.
//

import SwiftUI
import ExyteChat
import ActivityIndicatorView

@MainActor
struct ChatExampleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @StateObject var viewModel = ChatExampleViewModel()

    @State var text = ""

    let recorderSettings = RecorderSettings(sampleRate: 16000, numberOfChannels: 1, linearPCMBitDepth: 16)
    
    var body: some View {
        ChatView(messages: viewModel.messages, chatType: .conversation) { draft in
            viewModel.send(draft: draft)
        }
        .enableLoadMoreNewerMessages(triggerType: .pixels(0), hasMoreToLoad: viewModel.newPagesCount < viewModel.maxNewPagesCount) {
            await viewModel.loadNewerMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleBlue))
        }
        .enableLoadMoreOlderMessages(triggerType: .pixels(0)) {
            await viewModel.loadOlderMessagesPage()
        } loadingIndicatorBuilder: {
            activityIndicatorView
                .foregroundStyle(Color(.exampleGrey))
        }
        .mainHeaderBuilder { mainHeaderView }
        .updateTransaction($viewModel.tableTransaction)
        .scrollTo(viewModel.scrollToParams)
        .inputViewText($text)
        .keyboardDismissMode(.interactive)
        .setMediaPickerLiveCameraStyle(.prominant)
        .setRecorderSettings(recorderSettings)
        .messageReactionDelegate(viewModel)
        .swipeActions(edge: .leading, performsFirstActionWithFullSwipe: true, items: [replyAction])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            backToolbarItem
            titleToolbarItem
        }
        .onAppear(perform: viewModel.onStart)
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

    var replyAction: SwipeAction {
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
    }

    var backToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image("backArrow", bundle: .current)
                    .renderingMode(.template)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
    }

    var titleToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                let steve = MockChatData().steve
                if let url = steve.avatar {
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
                        Text(steve.name)
                            .fontWeight(.semibold)
                            .font(.headline)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        Text("online")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "AFB3B8"))
                    }
                }
            }
            .padding(.leading, 10)
        }
    }

    var mainHeaderView: some View {
        Text("This view is on top")
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(Color(.exampleBlue))
            .cornerRadius(10)
            .padding(.horizontal, 15)
    }
}
