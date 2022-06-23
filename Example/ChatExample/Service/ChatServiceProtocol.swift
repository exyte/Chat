//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Combine

protocol ChatServiceProtocol {
    var messages: AnyPublisher<[MyMessage], Never> { get }

    func send(message: String)
    func loadMessages() -> Future<Void, ChatError>
}
