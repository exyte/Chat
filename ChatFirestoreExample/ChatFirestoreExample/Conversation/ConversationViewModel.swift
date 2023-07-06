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
    public var mediaURLs: [String]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?
}

@MainActor
class ConversationViewModel: ObservableObject {

    var users: [User] // not including current user
    var allUsers: [User]

    var conversationDocument: DocumentReference
    var messagesCollection: CollectionReference

    @Published var messages: [Message] = []

    init(user: User) {
        self.users = [user]
        self.allUsers = [user]
        if let currentUser = SessionManager.shared.currentUser {
            self.allUsers.append(currentUser)
        }
        self.conversationDocument = Firestore.firestore()
            .collection(Collection.conversations)
            .document(user.id)
        self.messagesCollection = conversationDocument
            .collection(Collection.messages)
    }

    init(conversation: Conversation) {
        self.users = conversation.users.filter { $0.id != SessionManager.shared.currentUserId }
        self.allUsers = conversation.users
        self.conversationDocument = Firestore.firestore()
            .collection(Collection.conversations)
            .document(conversation.id)
        self.messagesCollection = conversationDocument
            .collection(Collection.messages)
    }

    func getConversation() {
        messagesCollection
            .order(by: "createdAt", descending: false)
            .addSnapshotListener() { [weak self] (snapshot, _) in
                let messages = snapshot?.documents
                    .compactMap { try? $0.data(as: FirestoreMessage.self) }
                    .compactMap { firestoreMessage -> Message? in
                        guard
                            let id = firestoreMessage.id,
                            let user = self?.allUsers.first(where: { $0.id == firestoreMessage.userId }),
                            let date = firestoreMessage.createdAt
                        else { return nil }

                        let attachments = firestoreMessage.mediaURLs.map {
                            Attachment(id: UUID().uuidString, url: URL(string: $0)!, type: .image)
                        }
                        return Message(id: id,
                                       user: user,
                                       status: .sent,
                                       createdAt: date,
                                       text: firestoreMessage.text,
                                       attachments: attachments,
                                       recording: firestoreMessage.recording,
                                       replyMessage: firestoreMessage.replyMessage)
                    }
                self?.messages = messages ?? []
            }
    }

    func sendMessage(_ draft: DraftMessage) {
        Task {
            // only create individual conversation when first message is sent
            // group conversation was created before
            if users.count == 1, messages.isEmpty {
                await createIndividualConversation(allUsers)
            }

            guard let user = SessionManager.shared.currentUser else { return }
            let id = UUID().uuidString
            let message = await Message.makeMessage(id: id, user: user, status: .sending, draft: draft)
            messages.append(message)

            let mediaURLs = await draft.medias.asyncMap {
                await UploadingManager.uploadMedia($0)?.absoluteString
            }

            let dict = [
                "userId": user.id,
                "createdAt": Timestamp(date: message.createdAt),
                "text": draft.text,
                "mediaURLs": mediaURLs
            ]

            messagesCollection.document(id).setData(dict) { [weak self] err in
                if let err = err {
                    print("Error adding document: \(err)")
                    if let index = self?.messages.lastIndex(where: { $0.id == id }) {
                        self?.messages[index].status = .error(draft)
                    }
                } else {
                    if let index = self?.messages.lastIndex(where: { $0.id == id }) {
                        self?.messages[index].status = .sent
                    }
                }
            }
        }
    }

    func createIndividualConversation(_ users: [User]) async {
        await withCheckedContinuation { continuation in
            conversationDocument
                .setData([
                    "users": users.map { $0.id }
                ]) { err in
                    if let err = err {
                        print(err)
                    }
                    continuation.resume()
                }
        }
    }
}
