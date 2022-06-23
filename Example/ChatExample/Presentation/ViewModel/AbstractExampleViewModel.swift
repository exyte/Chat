//
//  Created by Alex.M on 23.06.2022.
//

import Foundation
import Chat

class AbstractExampleViewModel: ObservableObject {
    @Published var messages: [Message] = []

    func send(draft: DraftMessage) {
        fatalError()
    }

    func onStart() {
        fatalError()
    }
}
