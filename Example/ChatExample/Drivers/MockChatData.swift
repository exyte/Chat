//
//  Created by Alex.M on 27.06.2022.
//

import Foundation

final class MockChatData {

    // Alternative for avatars `https://ui-avatars.com/api/?name=Tim`
    let system = MockUser(uid: "0", name: "System")
    let tim = MockUser(
        uid: "1",
        name: "Tim",
        avatar: URL(string: "https://this-person-does-not-exist.com/img/avatar-2dab5d540b8f76bf9ac2d7e3b40ac6c6.jpg")!
    )

    let steve = MockUser(
        uid: "2",
        name: "Steve",
        avatar: URL(string: "https://this-person-does-not-exist.com/img/avatar-d14a29b9d202c209d7cb4f0aa7ae1288.jpg")!
    )
    let emma = MockUser(
        uid: "3",
        name: "Steven",
        avatar: URL(string: "https://this-person-does-not-exist.com/img/avatar-3b27bd49907661e9ded749df27736232.jpg")!
    )

    func randomMessage(senders: [MockUser] = [], date: Date? = nil) -> MockMessage {
        let senders = senders.isEmpty ? [tim, steve, emma] : senders
        let sender = senders.random()!
        let date = date ?? Date()

        return MockMessage(
            uid: Int.random(),
            sender: sender,
            createdAt: date,
            text: Lorem.sentence()
        )
    }
}

