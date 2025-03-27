//
//  LinkPresentation+Metadata.swift
//  Chat
//
//  Created by Matthew Fennell on 25/03/2025.
//

import Foundation
import LinkPresentation

/// This enum models the types of metadata we can provide to an LPLinkView.
/// LPLinkView provides two constructors: one taking a URL and another taking LPLinkMetadata.
/// The URL variant creates a placeholder view, while the provider is loading the metadata.
/// Once the provider has loaded the data, we can use the LPLinkMetadata variant, which creates a view enriched with the given metadata.
public enum LinkPreviewMetadata {
    case placeholder(for: URL)
    case enriched(with: LPLinkMetadata)
}
