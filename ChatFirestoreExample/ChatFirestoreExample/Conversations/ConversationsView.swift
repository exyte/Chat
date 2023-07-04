//
//  ConversationsView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 03.07.2023.
//

import SwiftUI
import ActivityIndicatorView

struct ConversationsView: View {
    @StateObject var viewModel = ConversationsViewModel()

    @State var navPath = NavigationPath()
    @State var showActivityIndicator = false

    var body: some View {
        ZStack {
            content

            if showActivityIndicator {
                Color.black.opacity(0.8)
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                ActivityIndicatorView(isVisible: .constant(true), type: .flickeringDots())
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
            }
        }
        .task {
            viewModel.getData()
        }
    }

    var content: some View {
        NavigationStack(path: $navPath) {
            List(viewModel.groupConversations) { conversation in
                NavigationLink(value: conversation) {
                    HStack {
                        HStack(spacing: -30) {
                            ForEach(conversation.users) { user in
                                AvatarView(url: user.avatarURL, size: 40)
                            }
                        }
                        ForEach(conversation.users) { user in
                            if user.id == conversation.users.last?.id {
                                Text(user.name)
                            } else {
                                Text(user.name + ", ")
                            }
                        }
                    }
                }

                ForEach(viewModel.individualConversations) { conversation in
                    if let user = conversation.users.first {
                        NavigationLink(value: conversation) {
                            HStack {
                                AvatarView(url: user.avatarURL, size: 40)
                                Text(user.name)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Conversation.self) { conversation in
                ConversationView(viewModel: ConversationViewModel(conversation: conversation))
            }
            .navigationDestination(for: User.self) { user in
                ConversationView(viewModel: ConversationViewModel(user: user))
            }
            .navigationDestination(for: NavigationLinkToUsers.self) { _ in
                UsersView(viewModel: UsersViewModel(users: viewModel.users, allUsers: viewModel.allUsers), navPath: $navPath)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        AvatarView(url: SessionManager.shared.currentUser?.avatarURL, size: 44)
                        Text(SessionManager.shared.currentUser?.name ?? "")
                    }
                }
                ToolbarItem {
                    Button("+") {
                        navPath.append(NavigationLinkToUsers())
                    }
                }
                ToolbarItem {
                    Button("Logout") {
                        SessionManager.shared.logout()
                    }
                }
            }
        }
    }
}

struct NavigationLinkToUsers: Hashable { }

#Preview {
    ConversationsView()
}
