//
//  UsersView.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import SwiftUI

struct UsersView: View {

    @StateObject var viewModel = UsersViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.users) { user in
                NavigationLink(user.name, value: user)
            }
            .navigationDestination(for: User.self) { user in
                ConversationView(viewModel: ConversationViewModel(users: [user]))
            }
            .task {
                viewModel.getUsers()
            }
            .toolbar {
                ToolbarItem {
                    Button("Logout") {
                        SessionManager.shared.logout()
                    }
                }
            }
        }
    }
}
