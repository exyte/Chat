//
//  ActiveChatExampleViewModel.swift
//  ChatExample
//
//  Created by Alisa Mylnikova on 08.05.2026.
//

import Foundation
import ExyteChat

@MainActor
final class ActiveChatExampleViewModel: ObservableObject, ReactionDelegate {

    @Published var messages: [Message] = []
    @Published var users: [User] = []

    private let interactor = MockChatInteractor(isActive: true)
    private var timer: Timer?

    init() {
        Task {
            self.users = await interactor.otherSenders.map { $0.toChatUser() }
        }
    }

    func send(draft: DraftMessage) {
        Task {
            await interactor.send(draftMessage: draft)
            self.messages = await self.convertMessages()
        }
    }

    func remove(messageID: String) {
        Task {
            await interactor.remove(messageID: messageID)
            self.messages = await self.convertMessages()
        }
    }

    nonisolated func didReact(to message: Message, reaction draftReaction: DraftReaction) {
        Task {
            await interactor.add(draftReaction: draftReaction, to: draftReaction.messageID)
        }
    }

    func onStart() {
        Task {
            self.messages = await self.convertMessages()
            connect()
        }
    }

    func connect() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            Task { @MainActor in
                await self.interactor.timerTick()
                self.messages = await self.convertMessages()
            }
        }
    }

    func onStop() {
        timer?.invalidate()
    }

    func convertMessages() async -> [Message] {
        await interactor.messages.compactMap { $0.toChatMessage() }
    }
}
