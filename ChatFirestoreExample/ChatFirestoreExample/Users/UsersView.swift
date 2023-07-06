//
//  UsersView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI
import ActivityIndicatorView

struct UsersView: View {

    @StateObject var viewModel: UsersViewModel
    @Binding var navPath: NavigationPath

    @State var showSelection: Bool = false
    @State var selectedUsers: [User] = []

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
    }

    var content: some View {
        List(viewModel.users) { user in
            HStack {
                AvatarView(url: user.avatarURL, size: 40)
                Text(user.name)

                Spacer()

                if showSelection {
                    (selectedUsers.contains(user) ? Image(systemName: "checkmark.circle") : Image(systemName: "circle"))
                        .onTapGesture {
                            selectedUsers.contains(user) ? selectedUsers.removeAll(where: { $0.id == user.id }) : selectedUsers.append(user)
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                navPath.removeLast()
                navPath.append(user)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack {
                    AvatarView(url: SessionManager.shared.currentUser?.avatarURL, size: 44)
                    Text(SessionManager.shared.currentUser?.name ?? "")
                }
            }
            ToolbarItem {
                if selectedUsers.count > 1 {
                    Button("Go") {
                        Task {
                            showActivityIndicator = true
                            if let conversation = await viewModel.createConversation(selectedUsers) {
                                showActivityIndicator = false
                                selectedUsers = []
                                showSelection = false
                                navPath.removeLast()
                                navPath.append(conversation)
                            }
                        }
                    }
                } else {
                    Button(showSelection ? "Cancel" : "Group") {
                        selectedUsers = []
                        showSelection.toggle()
                    }
                }
            }
        }
    }
}
