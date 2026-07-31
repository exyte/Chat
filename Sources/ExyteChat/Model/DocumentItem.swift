//
//  DocumentItem.swift
//  Chat
//

import Foundation

/// A document selected by the user in the composer, before it becomes an `Attachment` on a sent `Message`.
public struct DocumentItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let url: URL
    public let fileName: String
    public let fileSize: Int?

    public init(id: String = UUID().uuidString, url: URL, fileName: String? = nil, fileSize: Int? = nil) {
        self.id = id
        self.url = url
        self.fileName = fileName ?? url.lastPathComponent
        self.fileSize = fileSize
    }
}
