//
//  WrappingMessagesTest.swift
//  Chat
//
//  Created by Matthew Fennell on 17/02/2025.
//

import SwiftUI
import Testing

@testable import ExyteChat

extension Tag {
    @Tag static var messageOrder: Self
    @Tag static var answerMode: Self
    @Tag static var quoteMode: Self
    @Tag static var positionInUserGroupAndMessagesSection: Self
    @Tag static var positionInCommentsGroup: Self
}

// In these tests, for convenience, we assert rows in the order they are displayed in the chat.
// That means - in conversation mode - the latest message (rows[0]) is at the bottom.
// For comments mode, this is reversed and the most recent message is at the top.
// Note that this is a presentational decision and handled above WrappingMessages.
struct WrappingMessagesTest {
    typealias ConcreteChatView = ChatView<EmptyView, EmptyView, DefaultMessageMenuAction>

    let romeo = User(id: "romeo", name: "Romeo Montague", avatarURL: nil, isCurrentUser: true)
    let juliet = User(id: "juliet", name: "Juliet Capulet", avatarURL: nil, isCurrentUser: false)

    let monday = try! Date.iso8601Date.parse("2025-01-27")
    let tuesday = try! Date.iso8601Date.parse("2025-01-28")

    @Test("No messages implies no sections", arguments: ChatType.allCases, ReplyMode.allCases)
    func noMessageImpliesNoSection(for chatType: ChatType, and replyMode: ReplyMode) {
        let sections = ConcreteChatView.mapMessages(
            [], chatType: chatType, replyMode: replyMode)

        #expect(sections.isEmpty)
    }

    @Test(
        "Message rows are ordered starting with the latest message", .tags(.messageOrder),
        arguments: ChatType.allCases, ReplyMode.allCases)
    func messageOrderIsReversed(for chatType: ChatType, and replyMode: ReplyMode) {
        let earlierMessage = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let laterMessage = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday))
        let sections = ConcreteChatView.mapMessages(
            [earlierMessage, laterMessage], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 2)

        #expect(sections.first?.rows[1].id == earlierMessage.id)
        #expect(sections.first?.rows[0].id == laterMessage.id)
    }

    @Test(
        "Message order is determined by the order in which messages are passed, not the date they were created",
        .tags(.messageOrder), arguments: ChatType.allCases, ReplyMode.allCases)
    func messageOrderIsBasedOnOrderTheyArePassed(for chatType: ChatType, and replyMode: ReplyMode) {
        let laterMessage = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday))
        let earlierMessage = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let sections = ConcreteChatView.mapMessages(
            [laterMessage, earlierMessage], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 2)

        #expect(sections.first?.rows[1].id == laterMessage.id)
        #expect(sections.first?.rows[0].id == earlierMessage.id)
    }

    @Test(
        "Messages on different days are always grouped by day, but out-of-order messages remain out of order within the day",
        .tags(.messageOrder), arguments: ChatType.allCases, ReplyMode.allCases)
    func messagesAreAlwaysGroupedByDays(for chatType: ChatType, and replyMode: ReplyMode) {
        let mondayLaterMessage = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday))
        let tuesdayMessage = Message(id: UUID().uuidString, user: romeo, createdAt: tuesday)
        let mondayEarlierMessage = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let sections = ConcreteChatView.mapMessages(
            [mondayLaterMessage, tuesdayMessage, mondayEarlierMessage], chatType: chatType,
            replyMode: replyMode)

        #expect(sections.count == 2)

        let mondaySection = sections[1]
        let tuesdaySection = sections[0]

        #expect(mondaySection.date.isSameDay(monday))
        #expect(tuesdaySection.date.isSameDay(tuesday))

        #expect(mondaySection.rows.count == 2)
        #expect(mondaySection.rows[1].id == mondayLaterMessage.id)
        #expect(mondaySection.rows[0].id == mondayEarlierMessage.id)

        #expect(tuesdaySection.rows.count == 1)
        #expect(tuesdaySection.rows[0].id == tuesdayMessage.id)
    }

    @Test(
        "When using answer mode, replies on a different day are included in the parent's day",
        .tags(.messageOrder, .answerMode), arguments: ChatType.allCases, [ReplyMode.answer])
    func repliesAreShownOnDateOfParentInAnswerMode(for chatType: ChatType, and replyMode: ReplyMode)
    {
        let parent = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let reply = Message(
            id: UUID().uuidString, user: romeo, createdAt: tuesday,
            replyMessage: parent.toReplyMessage())
        let sections = ConcreteChatView.mapMessages(
            [parent, reply], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first!.date.isSameDay(monday))
        #expect(sections.first!.rows.count == 2)
    }

    @Test(
        "When using quote mode, replies on a different day are included in their own day",
        .tags(.messageOrder, .quoteMode), arguments: ChatType.allCases, [ReplyMode.quote])
    func repliesAreShownOnDateOfReplyInQuoteMode(for chatType: ChatType, and replyMode: ReplyMode) {
        let parent = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let reply = Message(
            id: UUID().uuidString, user: romeo, createdAt: tuesday,
            replyMessage: parent.toReplyMessage())
        let sections = ConcreteChatView.mapMessages(
            [parent, reply], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 2)

        let mondaySection = sections[1]
        let tuesdaySection = sections[0]

        #expect(mondaySection.date.isSameDay(monday))
        #expect(tuesdaySection.date.isSameDay(tuesday))

        #expect(mondaySection.rows.count == 1)
        #expect(mondaySection.rows.first?.id == parent.id)

        #expect(tuesdaySection.rows.count == 1)
        #expect(tuesdaySection.rows.first?.id == reply.id)
    }

    @Test(
        "When using answer mode, nested replies are not shown", .tags(.messageOrder, .answerMode),
        arguments: ChatType.allCases, [ReplyMode.answer])
    func nestedRepliesAreHiddenInAnswerMode(for chatType: ChatType, and replyMode: ReplyMode) {
        let parent = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let reply = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday),
            replyMessage: parent.toReplyMessage())
        let nestedReply = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 2, since: monday),
            replyMessage: reply.toReplyMessage())
        let sections = ConcreteChatView.mapMessages(
            [parent, reply, nestedReply], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 2)

        switch chatType {
        case .comments:
            #expect(sections.first?.rows[0].id == parent.id)
            #expect(sections.first?.rows[1].id == reply.id)
        case .conversation:
            #expect(sections.first?.rows[1].id == parent.id)
            #expect(sections.first?.rows[0].id == reply.id)
        }
    }

    @Test(
        "When using quote mode, nested replies are shown", .tags(.messageOrder, .quoteMode),
        arguments: ChatType.allCases, [ReplyMode.quote])
    func nestedRepliesAreShownInQuoteMode(for chatType: ChatType, and replyMode: ReplyMode) {
        let parent = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let reply = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday),
            replyMessage: parent.toReplyMessage())
        let nestedReply = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 2, since: monday),
            replyMessage: reply.toReplyMessage())
        let sections = ConcreteChatView.mapMessages(
            [parent, reply, nestedReply], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 3)

        switch chatType {
        case .comments:
            #expect(sections.first?.rows[0].id == nestedReply.id)
            #expect(sections.first?.rows[1].id == reply.id)
            #expect(sections.first?.rows[2].id == parent.id)
        case .conversation:
            #expect(sections.first?.rows[2].id == parent.id)
            #expect(sections.first?.rows[1].id == reply.id)
            #expect(sections.first?.rows[0].id == nestedReply.id)
        }
    }

    @Test(
        "Single message has single position in user group",
        .tags(.positionInUserGroupAndMessagesSection),
        arguments: ChatType.allCases, ReplyMode.allCases)
    func singleMessageHasSinglePositionInUserGroup(for chatType: ChatType, and replyMode: ReplyMode)
    {
        let singleMessage = Message(id: UUID().uuidString, user: romeo)
        let sections = ConcreteChatView.mapMessages(
            [singleMessage], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 1)
        #expect(sections.first?.rows.first?.id == singleMessage.id)

        #expect(sections.first?.rows.first?.positionInUserGroup == .single)
        #expect(sections.first?.rows.first?.positionInMessagesSection == .single)
    }

    @Test(
        "Multiple messages from single user have top, middle and bottom positions in user group",
        .tags(.positionInUserGroupAndMessagesSection), arguments: ChatType.allCases,
        ReplyMode.allCases)
    func multipleMessagesFromSingleUserHaveCorrectUserGroupPositions(
        for chatType: ChatType, and replyMode: ReplyMode
    ) {
        let message0 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 0, since: monday))
        let message1 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday))
        let message2 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 2, since: monday))
        let sections = ConcreteChatView.mapMessages(
            [message0, message1, message2], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 3)

        #expect(sections.first?.rows[0].id == message2.id)
        #expect(sections.first?.rows[1].id == message1.id)
        #expect(sections.first?.rows[2].id == message0.id)

        switch chatType {
        case .comments:
            #expect(sections.first?.rows[0].positionInUserGroup == .first)
            #expect(sections.first?.rows[0].positionInMessagesSection == .first)

            #expect(sections.first?.rows[1].positionInUserGroup == .middle)
            #expect(sections.first?.rows[1].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[2].positionInUserGroup == .last)
            #expect(sections.first?.rows[2].positionInMessagesSection == .last)
        case .conversation:
            #expect(sections.first?.rows[2].positionInUserGroup == .first)
            #expect(sections.first?.rows[2].positionInMessagesSection == .first)

            #expect(sections.first?.rows[1].positionInUserGroup == .middle)
            #expect(sections.first?.rows[1].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[0].positionInUserGroup == .last)
            #expect(sections.first?.rows[0].positionInMessagesSection == .last)
        }
    }

    @Test(
        "Message from another user, in between many messages by another, splits the user group",
        .tags(.positionInUserGroupAndMessagesSection), arguments: ChatType.allCases,
        ReplyMode.allCases)
    func messageFromAnotherUserSplitsUserGroup(for chatType: ChatType, and replyMode: ReplyMode) {
        let message0 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 0, since: monday))
        let message1 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 1, since: monday))
        let message2 = Message(
            id: UUID().uuidString, user: juliet, createdAt: Date(timeInterval: 2, since: monday))
        let message3 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 3, since: monday))
        let message4 = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 4, since: monday))
        let sections = ConcreteChatView.mapMessages(
            [message0, message1, message2, message3, message4], chatType: chatType,
            replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 5)

        switch chatType {
        case .comments:
            #expect(sections.first?.rows[0].positionInUserGroup == .first)
            #expect(sections.first?.rows[0].positionInMessagesSection == .first)

            #expect(sections.first?.rows[1].positionInUserGroup == .last)
            #expect(sections.first?.rows[1].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[2].positionInUserGroup == .single)
            #expect(sections.first?.rows[2].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[3].positionInUserGroup == .first)
            #expect(sections.first?.rows[3].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[4].positionInUserGroup == .last)
            #expect(sections.first?.rows[4].positionInMessagesSection == .last)
        case .conversation:
            #expect(sections.first?.rows[4].positionInUserGroup == .first)
            #expect(sections.first?.rows[4].positionInMessagesSection == .first)

            #expect(sections.first?.rows[3].positionInUserGroup == .last)
            #expect(sections.first?.rows[3].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[2].positionInUserGroup == .single)
            #expect(sections.first?.rows[2].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[1].positionInUserGroup == .first)
            #expect(sections.first?.rows[1].positionInMessagesSection == .middle)

            #expect(sections.first?.rows[0].positionInUserGroup == .last)
            #expect(sections.first?.rows[0].positionInMessagesSection == .last)
        }
    }

    @Test(
        "Messages from the same user on different days should not be in the same user group",
        .tags(.positionInUserGroupAndMessagesSection), arguments: ChatType.allCases,
        ReplyMode.allCases)
    func messagesOnDifferentDaysShouldBeInDifferentUserGroups(
        for chatType: ChatType, and replyMode: ReplyMode
    ) {
        let message0 = Message(id: UUID().uuidString, user: romeo, createdAt: monday)
        let message1 = Message(id: UUID().uuidString, user: romeo, createdAt: tuesday)
        let sections = ConcreteChatView.mapMessages(
            [message0, message1], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 2)
        #expect(sections[1].rows.count == 1)
        #expect(sections[0].rows.count == 1)

        #expect(sections[1].rows.first?.id == message0.id)
        #expect(sections[0].rows.first?.id == message1.id)

        #expect(sections[1].rows.first?.positionInUserGroup == .single)
        #expect(sections[1].rows.first?.positionInMessagesSection == .single)

        #expect(sections[0].rows.first?.positionInUserGroup == .single)
        #expect(sections[0].rows.first?.positionInMessagesSection == .single)
    }

    @Test(
        "Comments position should be set for answer reply mode", .tags(.answerMode),
        arguments: ChatType.allCases, [ReplyMode.answer])
    func commentsPositionShouldBeSetInAnswerMode(for chatType: ChatType, and replyMode: ReplyMode) {
        let message = Message(id: UUID().uuidString, user: romeo)
        let sections = ConcreteChatView.mapMessages(
            [message], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 1)
        #expect(sections.first?.rows.first?.commentsPosition != nil)
    }

    @Test(
        "Comments position should not be set for quote reply mode", .tags(.quoteMode),
        arguments: ChatType.allCases, [ReplyMode.quote])
    func commentsPositionShouldNotBeSetInQuoteMode(for chatType: ChatType, and replyMode: ReplyMode)
    {
        let message = Message(id: UUID().uuidString, user: romeo)
        let sections = ConcreteChatView.mapMessages(
            [message], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 1)
        #expect(sections.first?.rows.first?.commentsPosition == nil)
    }

    @Test(
        "Single post should be at top level", .tags(.positionInCommentsGroup),
        arguments: ChatType.allCases, [ReplyMode.answer])
    func singlePostShouldBeAtTopLevel(for chatType: ChatType, and replyMode: ReplyMode) {
        let message = Message(id: UUID().uuidString, user: romeo)
        let sections = ConcreteChatView.mapMessages(
            [message], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 1)

        #expect(sections.first?.rows.first?.commentsPosition?.inChat == .single)
        #expect(sections.first?.rows.first?.commentsPosition?.inSection == .single)
        #expect(
            sections.first?.rows.first?.commentsPosition?.inCommentsGroup == .singleFirstLevelPost)
    }

    @Test(
        "Reply should be in comments level", .tags(.positionInCommentsGroup),
        arguments: ChatType.allCases, [ReplyMode.answer])
    func replyShouldBeInCommentsLevel(for chatType: ChatType, and replyMode: ReplyMode) {
        let topLevel = Message(
            id: UUID().uuidString, user: romeo, createdAt: Date(timeInterval: 0, since: monday))
        let reply = Message(
            id: UUID().uuidString, user: juliet, createdAt: Date(timeInterval: 1, since: monday),
            replyMessage: topLevel.toReplyMessage())
        let sections = ConcreteChatView.mapMessages(
            [topLevel, reply], chatType: chatType, replyMode: replyMode)

        #expect(sections.count == 1)
        #expect(sections.first?.rows.count == 2)

        switch chatType {
        case .comments:
            #expect(sections.first?.rows[0].id == topLevel.id)
            #expect(sections.first?.rows[1].id == reply.id)
        case .conversation:
            #expect(sections.first?.rows[1].id == topLevel.id)
            #expect(sections.first?.rows[0].id == reply.id)
        }

        let topLevelIndex = chatType == .conversation ? 1 : 0
        let replyIndex = chatType == .conversation ? 0 : 1

        #expect(sections.first?.rows[topLevelIndex].commentsPosition?.inChat == .first)
        #expect(sections.first?.rows[topLevelIndex].commentsPosition?.inSection == .first)
        #expect(
            sections.first?.rows[topLevelIndex].commentsPosition?.inCommentsGroup
                == .firstLevelPostWithComments)

        #expect(sections.first?.rows[replyIndex].commentsPosition?.inChat == .last)
        #expect(sections.first?.rows[replyIndex].commentsPosition?.inSection == .last)
        #expect(sections.first?.rows[replyIndex].commentsPosition?.inCommentsGroup == .lastComment)
    }
}
