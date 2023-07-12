//
//  ConversationsViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 03.07.2023.
//

import Foundation
import FirebaseFirestore

@MainActor
class ConversationsViewModel: ObservableObject {

    @Published var users: [User] = [] // not including current user
    @Published var allUsers: [User] = []

    @Published var searchText = ""

    @Published var conversations: [Conversation] = []
    var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return conversations
        }
        return conversations.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }

    @Published var showActivityIndicator = false

    func getData() async {
        showActivityIndicator = true
        await getUsers()
        await getConversations()
        showActivityIndicator = false
    }

    func getUsers() async {
        let snapshot = try? await Firestore.firestore()
            .collection(Collection.users)
            .getDocuments()
        storeUsers(snapshot)
    }

    func getConversations() async {
        let snapshot = try? await Firestore.firestore()
            .collection(Collection.conversations)
            .whereField("users", arrayContains: SessionManager.shared.currentUserId)
            .getDocuments()
        storeConversations(snapshot)
    }

    func subscribeToUpdates() {
        Firestore.firestore()
            .collection(Collection.users)
            .addSnapshotListener { [weak self] (snapshot, _) in
                guard let self else { return }
                self.storeUsers(snapshot)
                Task {
                    await self.getConversations() // update in case some new user didn't make it in time for conversations subscription
                }
            }

        Firestore.firestore()
            .collection(Collection.conversations)
            .whereField("users", arrayContains: SessionManager.shared.currentUserId)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                self?.storeConversations(snapshot)
            }
    }

    private func storeUsers(_ snapshot: QuerySnapshot?) {
        guard let currentUser = SessionManager.shared.currentUser else { return }
        users = snapshot?.documents
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
        allUsers = users + [currentUser]
    }

    private func storeConversations(_ snapshot: QuerySnapshot?) {
        conversations = snapshot?.documents
            .compactMap { [weak self] document in
                if let firestoreConversation = try? document.data(as: FirestoreConversation.self) {
                    return self?.makeConversation(document.documentID, firestoreConversation)
                }
                return nil
            } ?? []
    }

    private func makeConversation(_ id: String, _ firestoreConversation: FirestoreConversation) -> Conversation {
        var message: LatestMessageInChat? = nil
        if let flm = firestoreConversation.latestMessage,
           let user = allUsers.first(where: { $0.id == flm.userId }) {
            var subtext: String?
            if !flm.mediaURLs.isEmpty {
                subtext = "Media"
            } else if flm.recording != nil {
                subtext = "Voice recording"
            }
            message = LatestMessageInChat(
                senderName: user.id == SessionManager.shared.currentUserId ? "You" : user.name,
                createdAt: flm.createdAt,
                text: flm.text.isEmpty ? nil : flm.text,
                subtext: subtext
            )
        }
        let users = firestoreConversation.users.compactMap { id in
            allUsers.first(where: { $0.id == id })
        }
        let conversation = Conversation(
            id: id,
            users: users,
            pictureURL: firestoreConversation.pictureURL?.toURL(),
            title: firestoreConversation.title,
            latestMessage: message
        )
        return conversation
    }
}
