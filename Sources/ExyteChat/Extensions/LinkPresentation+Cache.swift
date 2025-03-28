//
//  LinkPresentation+Cache.swift
//  Chat
//
//  Created by Matthew Fennell on 25/03/2025.
//

import Foundation
import LinkPresentation

/// Generating the metadata to display in a link preview is expensive, and would occur every time we scroll past a message bubble with a link preview inside.
/// Therefore, we need a cache to prevent the enriched metadata from disappearing and reappearing every time we scroll past a message with a preview.
/// NSCache almost does what we want, but only works on class types, which doesn't work with the URL struct we'd like to use as the key.
/// Therefore: create a light wrapper around NSCache that does not require the caller to drop down to UIKit.
class LinkMetadataCache {

    private let nsCache = NSCache<NSURL, LPLinkMetadata>()

    public func insert(_ metadata: LPLinkMetadata, forURL url: URL) {
        nsCache.setObject(metadata, forKey: url as NSURL)
    }

    public func get(forURL url: URL) -> LPLinkMetadata? {
        nsCache.object(forKey: url as NSURL)
    }

}
