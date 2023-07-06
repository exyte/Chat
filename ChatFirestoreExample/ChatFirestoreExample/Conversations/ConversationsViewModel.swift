//
//  ConversationsViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 03.07.2023.
//

import Foundation
import FirebaseFirestore

class ConversationsViewModel: ObservableObject {

    @Published var users: [User] = [] // not including current user
    @Published var allUsers: [User] = []

    @Published var individualConversations: [Conversation] = []
    @Published var groupConversations: [Conversation] = []

    func getData() {
        Firestore.firestore()
            .collection(Collection.users)
            .getDocuments { [weak self] (snapshot, _) in
                guard let self, let currentUser = SessionManager.shared.currentUser else { return }
                self.users = snapshot?.documents
                    .compactMap { document in
                        let dict = document.data()
                        if document.documentID == currentUser.id {
                            return nil // skip current user
                        }
                        if let name = dict["nickname"] as? String {
                            let avatarURL = dict["avatarURL"] as? String
                            return User(id: document.documentID, name: name, avatarURL: URL(string: avatarURL ?? ""), isCurrentUser: false)
                        }
                        return nil
                    } ?? []
                self.allUsers = self.users + [currentUser]
                self.getMyChats()
            }
    }

    func getMyChats() {
        Firestore.firestore()
            .collection(Collection.conversations)
            .whereField("users", arrayContains: SessionManager.shared.currentUserId)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                self?.individualConversations = []
                self?.groupConversations = []

                snapshot?.documents
                    .forEach { document in
                        let userIds = document.data()["users"] as? [String] ?? []
                        self?.storeConversation(document.documentID, userIds)
                    }
            }
    }

    func storeConversation(_ id: String, _ userIds: [String]) {
        let users = userIds.compactMap { id in
            allUsers.first(where: { $0.id == id })
        }
        let conversation = Conversation(id: id, users: users)
        if userIds.count == 2 {
            individualConversations.append(conversation)
        } else if userIds.count > 2 {
            groupConversations.append(conversation)
        } else {
            fatalError("Wrong user count (\(userIds.count)) for conversation id: \(id) userIds: \(userIds)")
        }
    }
}
