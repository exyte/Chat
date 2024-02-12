//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

public enum PositionInGroup { // group from the same user
    case first
    case middle
    case last
    case single // the only message in its group
}

// for comments reply mode only

public enum PositionInCommentsGroup {
    case singleFirstLevelPost // post has no replies
    case firstLevelPost
    case latestFirstLevelPost

    case firstComment
    case middleComment
    case lastComment
    case latestCommentInLatestGroup

    public var isFirstLevel: Bool {
        [.singleFirstLevelPost, .firstLevelPost, .latestFirstLevelPost].contains(self)
    }

    public var isAReply: Bool {
        [.firstComment, .middleComment, .lastComment, .latestCommentInLatestGroup].contains(self)
    }

    public var isLastInGroup: Bool {
        [.lastComment, .singleFirstLevelPost].contains(self)
    }

    public var isLastInChat: Bool {
        [.latestFirstLevelPost, .latestCommentInLatestGroup].contains(self)
    }
}

struct MessageRow: Equatable {
    let message: Message
    let positionInGroup: PositionInGroup
    let positionInCommentsGroup: PositionInCommentsGroup?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.positionInGroup == rhs.positionInGroup
        && lhs.positionInCommentsGroup == rhs.positionInCommentsGroup
        && lhs.message.status == rhs.message.status
        && lhs.message.triggerRedraw == rhs.message.triggerRedraw
    }
}

extension MessageRow: Identifiable {
    public typealias ID = String
    public var id: String {
        return message.id
    }
}
