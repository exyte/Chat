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
        avatar: URL(string: "https://ui-avatars.com/api/?name=Tim")!
    )
    let steve = MockUser(
        uid: "2",
        name: "Steve",
        avatar: URL(string: "https://ui-avatars.com/api/?name=S+T")!
    )
    let emma = MockUser(
        uid: "3",
        name: "Emma",
        avatar: URL(string: "https://ui-avatars.com/api/?name=Emma")!
    )

    private var lastMessageId = 0

    func randomMessage(senders: [MockUser] = [], date: Date? = nil) -> MockMessage {
        let senders = senders.isEmpty ? [tim, steve, emma] : senders
        let sender = senders.random()!
        let date = date ?? Date()
        let images = randomImages()

        let shouldGenerateText = images.isEmpty ? true : .random()

        return MockMessage(
            uid: messageId(),
            sender: sender,
            createdAt: date,
            text: shouldGenerateText ? Lorem.sentence(useMarkdown: true) : "",
            images: images
        )
    }

    func randomImages() -> [MockImage] {
        guard Int.random(min: 0, max: 10) == 0 else {
            return []
        }

        let count = Int.random(min: 1, max: 5)
        return (0...count).map { _ in
            randomMockImage()
        }
    }

    func randomMockImage() -> MockImage {
        let color = randomColorHex()
        return MockImage(
            thumbnail: URL(string: "https://via.placeholder.com/150/\(color)")!,
            full: URL(string: "https://via.placeholder.com/600/\(color)")!
        )
    }

    func randomColorHex() -> String {
        (0...6)
            .map { _ in randomHexChar() }
            .joined()
    }
}

private extension MockChatData {
    func randomHexChar() -> String {
        let letters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
        return letters.random()!
    }

    func messageId() -> Int {
        lastMessageId += 1
        return lastMessageId
    }
}
