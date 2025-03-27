//
//  LinkMetadataCacheTest.swift
//  Chat
//
//  Created by Matthew Fennell on 09/03/2025.
//

import LinkPresentation
import Testing

@testable import ExyteChat

struct LinkMetadataCacheTest {

    @Test func shouldNotRetrieveMetadataForNotGivenUrl() async throws {
        let cache = LinkMetadataCache()
        let url = URL(string: "https://example.org")!

        let retrieved = cache.get(forURL: url)

        #expect(retrieved == nil)
    }

    @Test func shouldRetrieveMetadataWithGivenUrl() async throws {
        let cache = LinkMetadataCache()
        let metadata = LPLinkMetadata()
        let url = URL(string: "https://example.org")!
        cache.insert(metadata, forURL: url)

        let retrieved = cache.get(forURL: url)

        #expect(metadata == retrieved)
    }

}
