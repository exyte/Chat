//
//  FakeConversationsManager.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 14.07.2023.
//

import Foundation
import FirebaseFirestore

class FakeConversationsManager {

    /// add fake users and conversation so you don't feel alone

    func createFakesIfNeeded() {
        Task {
            // check if users were already created
            let usersSnapshot = try? await Firestore.firestore()
                .collection(Collection.users)
                .whereField("deviceId", isEqualTo: "0")
                .getDocuments()

            // if not - create both: users and conversations
            if usersSnapshot?.isEmpty ?? false {
                addFakeUsersWithConversations()
                return
            }

            // if yes - check if conversations were alreay created
            let snapshot = try? await Firestore.firestore()
                .collection(Collection.conversations)
                .whereField("users", arrayContains: SessionManager.shared.currentUserId)
                .getDocuments()

            // if not - create conversations with current user and every fake user
            let fakeConversations = snapshot?.documents.filter {
                if let c = try? $0.data(as: FirestoreConversation.self) {
                    return c.users.contains { ["Bob", "Steve", "Tim"].contains($0) }
                }
                return false
            } ?? []
            if fakeConversations.isEmpty {
                addFakeConversations()
            }
        }
    }

    func addFakeUsersWithConversations() {
        createNewUser(nickname: "Bob", imageName: "bob")
        createNewUser(nickname: "Steve", imageName: "steve")
        createNewUser(nickname: "Tim", imageName: "tim")
    }

    func addFakeConversations() {
        createIndividualConversation("Bob")
        createIndividualConversation("Steve")
        createIndividualConversation("Tim")
    }

    func createNewUser(nickname: String, imageName: String) {
        Task {
            guard let data = UIImage(named: imageName)?.jpegData(compressionQuality: 1.0),
                  let avatarURL = await UploadingManager.uploadImageData(data) else { return }

            try await Firestore.firestore()
                .collection(Collection.users)
                .document(nickname)
                .setData([
                    "deviceId": "0",
                    "nickname": nickname,
                    "avatarURL": avatarURL.absoluteString
                ])

            createIndividualConversation(nickname)
        }
    }

    private func createIndividualConversation(_ userId: String) {
        print("create conv")
        guard let currentUser = SessionManager.shared.currentUser else { return }
        let dict: [String : Any] = [
            "users": [userId, currentUser.id],
            "title": "a"
        ]

        Firestore.firestore()
            .collection(Collection.conversations)
            .addDocument(data: dict) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("created", [userId, currentUser.id])
                }
            }
    }
}
