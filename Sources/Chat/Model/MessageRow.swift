//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

public enum PositionInGroup {
    case first
    case middle
    case last
    case single // the only message in its group
}

struct MessageRow: Equatable {
    let message: Message
    let positionInGroup: PositionInGroup

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.positionInGroup == rhs.positionInGroup && lhs.message.status == rhs.message.status
    }
}

extension MessageRow: Identifiable {
    public typealias ID = String
    public var id: String {
        return message.id
    }
}

extension MessageRow {
    func toString() -> String {
        String("id: \(id) status: \(message.status) date: \(message.createdAt) position: \(positionInGroup)")
    }
}
