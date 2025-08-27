//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public enum UserType: Int, Codable, Sendable {
    case current = 0, other, system
}

public struct User: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let avatarURL: URL?
    public let avatarCacheKey: String?
    public let type: UserType
    public var isCurrentUser: Bool { type == .current }
    
    public init(id: String, name: String, avatarURL: URL?, avatarCacheKey: String? = nil, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarCacheKey = avatarCacheKey
        self.type = isCurrentUser ? .current : .other
    }
    
    public init(id: String, name: String, avatarURL: URL?, avatarCacheKey: String? = nil, type: UserType) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarCacheKey = avatarCacheKey
        self.type = type
    }
}
