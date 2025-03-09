//
//  CachedLinkPillView.swift
//  Chat
//
//  Created by Matthew Fennell on 09/03/2025.
//

import LinkPresentation
import SwiftUI

/// LinkPreviewView has two mutually exclusive cases - either displaying a placeholder, or enriched content.
/// To switch from one case to the other, you need to create a new view.
/// This is inconvenient for consumers since you have to keep track of whether the enriched metadata has loaded or not.
///
/// Therefore, this view manages this complexity, hiding the state of whether the enriched metadata is loaded or not.
/// Since this view is the only view generating link preview metadata, it also manages the cache.
struct CachedLinkPillView: View {

    @State var metadata: LinkPreviewMetadata
    private static let cache = LinkMetadataCache()

    init(url: URL) {
        guard let cached = Self.cache.get(forURL: url) else {
            metadata = .placeholder(for: url)
            return
        }
        metadata = .enriched(with: cached)
    }

    private func fetchMetadata(for url: URL) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { (metadata, _) in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    self.metadata = .enriched(with: metadata)
                    Self.cache.insert(metadata, forURL: url)
                }
            }
        }
    }

    var body: some View {
        switch metadata {
        case .placeholder(let url):
            LinkPillView(url: url)
                .onAppear {
                    fetchMetadata(for: url)
                }
        case .enriched(let metadata):
            LinkPillView(metadata: metadata)
        }
    }

}

#Preview {
    CachedLinkPillView(url: URL(string: "https://example.org")!)
}
