//
//  Location.swift
//  Chat
//

import Foundation

public struct Location: Codable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double
    /// Optional human-readable name/address for the pinned location
    public var title: String?

    public init(latitude: Double, longitude: Double, title: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
    }
}
