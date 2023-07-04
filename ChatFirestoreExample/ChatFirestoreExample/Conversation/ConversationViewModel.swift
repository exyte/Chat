//
//  ConversationViewModel.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 13.06.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Chat

public struct FirestoreMessage: Codable {

    @DocumentID public var id: String?
    public var userId: String
    @ServerTimestamp public var createdAt: Date?

    public var text: String
    public var attachments: [Attachment]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?
}

class ConversationViewModel: ObservableObject {

    var users: [User] // not including current user

    @Published var messages: [Message] = []

    private var allUsers: [User] {
        var all = users
        if let currentUser = SessionManager.shared.currentUser {
            all.append(currentUser)
        }
        return all
    }

    private var collection: CollectionReference {
        Firestore.firestore()
            .collection(Collection.conversations)
            .document("\(allUsers.sorted(by: { $0.id < $1.id }).reduce("") { $0 + $1.id })")
            .collection(Collection.messages)
    }

    init(users: [User]) {
        self.users = users
    }

    func getConversation() {
        collection
            .order(by: "createdAt", descending: false)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                print(snapshot?.documents.map{$0.data()})
                // print("alisa", snapshot?.documents.map{try? $0.data(as: Message.self) })
                print("alisa", try? snapshot?.documents.first?.data(as: FirestoreMessage.self))
                let messages = snapshot?.documents
                    .compactMap { try? $0.data(as: FirestoreMessage.self) }
                    .compactMap { firestoreMessage -> Message? in
                        guard
                            let id = firestoreMessage.id,
                            let user = self?.allUsers.first(where: { $0.id == firestoreMessage.userId }),
                            let date = firestoreMessage.createdAt
                        else { return nil }
                        return Message(id: id,
                                       user: user,
                                       status: .sent,
                                       createdAt: date,
                                       text: firestoreMessage.text,
                                       attachments: firestoreMessage.attachments,
                                       recording: firestoreMessage.recording,
                                       replyMessage: firestoreMessage.replyMessage)
                    }
                self?.messages = messages ?? []
            }
    }

    func sendMessage(_ draft: DraftMessage) {
        guard let user = SessionManager.shared.currentUser else { return }
        let id = UUID().uuidString
        let message = Message(id: id, user: user, status: .sending, draft: draft)
        messages.append(message)

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(draft) else { return }
        guard var dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
        dict["userId"] = user.id
        dict["createdAt"] = Timestamp(date: message.createdAt)
        print(dict)

        collection.document(id).setData(dict) { [weak self] err in
            if let err = err {
                print("Error adding document: \(err)")
                if let index = self?.messages.lastIndex(where: { $0.id == id }) {
                    self?.messages[index].status = .error
                }
            } else {
                if let index = self?.messages.lastIndex(where: { $0.id == id }) {
                    self?.messages[index].status = .sent
                }
            }
        }
    }
}
