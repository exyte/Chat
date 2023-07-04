//
//  UsersViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import Foundation
import FirebaseFirestore
import Chat

class UsersViewModel: ObservableObject {

    @Published var users: [User] = []

    var collection: CollectionReference {
        Firestore.firestore()
            .collection(Collection.users)
    }

    func getUsers() {
        collection.getDocuments { [weak self] (snapshot, _) in
            self?.users = snapshot?.documents
                .compactMap { document in
                    let dict = document.data()
                    if document.documentID == SessionManager.shared.currentUser?.id {
                        return nil // exclude current user
                    }
                    if let name = dict["nickname"] as? String {
                        return User(id: document.documentID, name: name, avatarURL: nil, isCurrentUser: false)
                    }
                    return nil
                } ?? []
        }
    }
}
