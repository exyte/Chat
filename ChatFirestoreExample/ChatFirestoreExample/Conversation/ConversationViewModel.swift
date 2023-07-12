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

@MainActor
class ConversationViewModel: ObservableObject {

    var users: [User] // not including current user
    var allUsers: [User]

    var conversation: Conversation?
    var messagesCollection: CollectionReference?

    @Published var messages: [Message] = []

    init(user: User) {
        self.users = [user]
        self.allUsers = [user]
        if let currentUser = SessionManager.shared.currentUser {
            self.allUsers.append(currentUser)
        }
        // setup conversation and messagesCollection later, after it's created
    }

    init(conversation: Conversation) {
        self.users = conversation.users.filter { $0.id != SessionManager.shared.currentUserId }
        self.allUsers = conversation.users
        self.conversation = conversation
        self.messagesCollection = makeMessagesCollectionRef(conversation)
    }

    func makeMessagesCollectionRef(_ conversation: Conversation) -> CollectionReference {
        Firestore.firestore()
            .collection(Collection.conversations)
            .document(conversation.id)
            .collection(Collection.messages)
    }

    func getConversation() {
        messagesCollection?
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
            // group conversation was created before (UsersViewModel)
            if users.count == 1, messages.isEmpty,
               let user = users.first,
               let conversation = await createIndividualConversation(user) {
                self.conversation = conversation
                self.messagesCollection = makeMessagesCollectionRef(conversation)
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

            do {
                try await messagesCollection?.document(id).setData(dict)
                if let index = messages.lastIndex(where: { $0.id == id }) {
                    messages[index].status = .sent
                }
            } catch {
                print("Error adding document: \(error)")
                if let index = messages.lastIndex(where: { $0.id == id }) {
                    messages[index].status = .error(draft)
                }
            }

            if let id = conversation?.id {
                try await Firestore.firestore()
                    .collection(Collection.conversations)
                    .document(id)
                    .updateData(["latestMessage" : dict])
            }
        }
    }

    private func createIndividualConversation(_ user: User) async -> Conversation? {
        let dict: [String : Any] = [
            "users": allUsers.map { $0.id },
            "pictureURL": user.avatarURL?.absoluteString ?? "",
            "title": user.name
        ]

        return await withCheckedContinuation { continuation in
            var ref: DocumentReference? = nil
            ref = Firestore.firestore()
                .collection(Collection.conversations)
                .addDocument(data: dict) { err in
                    if let _ = err {
                        continuation.resume(returning: nil)
                    } else if let id = ref?.documentID {
                        continuation.resume(returning: Conversation(id: id, users: self.allUsers, pictureURL: user.avatarURL, title: user.name, latestMessage: nil))
                    }
                }
        }
    }
}
