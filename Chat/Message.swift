//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI

struct Message: Equatable {

    var id: Int

    var text: String?
    var imagesURLs: [URL] = []
    var videosURLs: [URL] = []

    var createdAt: Date = Date()
    
    var avatarURL: URL?
    var isCurrentUser: Bool = false
}
