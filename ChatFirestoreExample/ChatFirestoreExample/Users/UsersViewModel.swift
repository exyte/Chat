//
//  UsersViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import Foundation
import FirebaseFirestore

class UsersViewModel: ObservableObject, Hashable {
    static func == (lhs: UsersViewModel, rhs: UsersViewModel) -> Bool {
        lhs.allUsers == rhs.allUsers
    }

    func hash(into hasher: inout Hasher) {
        
    }

    @Published var users: [User] // not including current user
    @Published var allUsers: [User]

    init(users: [User], allUsers: [User]) {
        self.users = users
        self.allUsers = allUsers
    }

    func createConversation(_ users: [User]) async -> Conversation? {
        await withCheckedContinuation { continuation in
            var ref: DocumentReference? = nil
            ref = Firestore.firestore()
                .collection(Collection.conversations)
                .addDocument(data: [
                    "users": users.map { $0.id } + [SessionManager.shared.currentUserId]
                ]) { err in
                    if let _ = err {
                        continuation.resume(returning: nil)
                    } else if let id = ref?.documentID {
                        continuation.resume(returning: Conversation(id: id, users: users))
                    }
                }
        }
    }
}
