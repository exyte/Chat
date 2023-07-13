//
//  Constants.swift
//  ChatFirestoreExample
//
//  Created by Alisa Mylnikova on 10.07.2023.
//

import SwiftUI
import Chat
import ExyteMediaPicker

struct Collection {
    static let users = "users"
    static let conversations = "conversations"
    static let messages = "messages"
}

var dataStorage = DataStorageManager.shared

public typealias User = Chat.User
public typealias Message = Chat.Message
public typealias Media = ExyteMediaPicker.Media
