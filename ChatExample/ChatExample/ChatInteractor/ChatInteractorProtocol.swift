//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import Combine
import ExyteChat

@MainActor
protocol ChatInteractorProtocol {
    var messages: AnyPublisher<[MockMessage], Never> { get }
    var senders: [MockUser] { get }
    var otherSenders: [MockUser] { get }

    func send(draftMessage: ExyteChat.DraftMessage)
    func remove(messageID: String)
    
    func add(draftReaction: DraftReaction, to messageID: String)

    func connect()
    func disconnect()

    func loadNextPage() -> Future<Bool, Never>
}
