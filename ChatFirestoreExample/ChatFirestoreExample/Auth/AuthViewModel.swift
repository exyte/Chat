//
//  AuthViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 12.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Collection {

    static let users = "users"
    static let conversations = "conversations"
    static let messages = "messages"
}

class AuthViewModel: ObservableObject {

    var collection: CollectionReference {
        Firestore.firestore()
            .collection(Collection.users)
    }

    func auth(nickname: String) {
        collection
            .whereField("deviceId", isEqualTo: SessionManager.shared.deviceId)
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments { [weak self] (snapshot, _) in
                if let id = snapshot?.documents.first?.documentID {
                    let user = User(id: id, name: nickname, avatarURL: nil, isCurrentUser: true)
                    SessionManager.shared.storeUser(user)
                } else {
                    self?.createNewUser(nickname: nickname)
                }
            }
    }

    func createNewUser(nickname: String) {
        var ref: DocumentReference? = nil
        ref = collection.addDocument(data: [
            "deviceId": SessionManager.shared.deviceId,
            "nickname": nickname
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else if let id = ref?.documentID {
                let user = User(id: id, name: nickname, avatarURL: nil, isCurrentUser: true)
                SessionManager.shared.storeUser(user)
            }
        }
    }
}
