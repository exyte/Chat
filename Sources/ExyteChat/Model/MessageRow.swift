//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

public enum PositionInUserGroup { // group from the same user
    case first
    case middle
    case last
    case single // the only message in its group

    var isTop: Bool {
        self == .first || self == .single
    }
}

public enum PositionInMessagesSection { // messages within the same day
    case first
    case middle
    case last
    case single

    var isTop: Bool {
        self == .first || self == .single
    }
}

// for comments reply mode only

public struct CommentsPosition: Equatable {
    public var inCommentsGroup: PositionInCommentsGroup
    public var inSection: PositionInSection
    public var inChat: PositionInChat

    public var isAComment: Bool {
        [.firstComment, .middleComment, .lastComment].contains(inCommentsGroup)
    }

    public var isLastInCommentsGroup: Bool {
        [.lastComment, .singleFirstLevelPost].contains(inCommentsGroup)
    }

    public var isLastInChat: Bool {
        [.last, .single].contains(inChat)
    }
}

public enum PositionInCommentsGroup {
    case singleFirstLevelPost // post has no comments
    case firstLevelPostWithComments

    case firstComment
    case middleComment
    case lastComment
}

public enum PositionInSection {
    case first
    case middle
    case last
    case single // the only message in its section
}

public enum PositionInChat {
    case first
    case middle
    case last
    case single // the only message in the chat
}

struct MessageRow: Equatable {
    let message: Message
    let positionInUserGroup: PositionInUserGroup
    let positionInMessagesSection: PositionInMessagesSection
    let commentsPosition: CommentsPosition?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.positionInUserGroup == rhs.positionInUserGroup
        && lhs.positionInMessagesSection == rhs.positionInMessagesSection
        && lhs.commentsPosition == rhs.commentsPosition
        && lhs.message == rhs.message
    }
}

extension MessageRow: Identifiable {
    public typealias ID = String
    public var id: String {
        return message.id
    }
}
