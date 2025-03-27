//
//  LinkPresentation+View.swift
//  Chat
//
//  Created by Matthew Fennell on 25/03/2025.
//

// LinkPresentation is not yet updated to support strict concurrency checking.
// LPLinkMetadata is not sendable; meanwhile, startFetchingMetadata(for:) uses a background thread and runs in a
// nonisolated context.
// Therefore, LPLinkMetadata is not usable from the main actor until Apple updates the library.
// Once LinkPresentation supports structured concurrency, we should remove the @preconcurrency annotation.
@preconcurrency import LinkPresentation
import SwiftUI

/// Lightweight wrapper around LPLinkView, that allows for more convenient use from SwiftUI.
private struct LinkViewRepresentable: UIViewRepresentable {

    let metadata: LinkPreviewMetadata

    func makeUIView(context: Context) -> LPLinkView {
        switch metadata {
        case .placeholder(let url):
            LPLinkView(url: url)
        case .enriched(let metadata):
            LPLinkView(metadata: metadata)
        }
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: LPLinkView, context: Context) -> CGSize?
    {
        let width = proposal.width ?? uiView.intrinsicContentSize.width
        let height = proposal.height ?? uiView.intrinsicContentSize.height
        return CGSize(width: width, height: height)
    }

}

/// In our default chat view, link previews appear in the message itself.
/// Inside the message, there is limited space, and if multiple links are given, the default link preview design, with title, image, video etc takes up too much space.
/// Unfortunately, Apple does not let us customise the LPLinkView presentation (e.g. hiding the preview image), apart from modifying the view's size.
/// Therefore, create a small wrapper around LinkViewRepresentable, which presents the preview in a small "pill" form.
private struct PlaceholderOrEnrichedLinkPillView: View {

    /// The largest height without the preview image/video becoming visible.
    private static let pillHeight: CGFloat = 53

    private let metadata: LinkPreviewMetadata

    init(url: URL) {
        self.metadata = LinkPreviewMetadata.placeholder(for: url)
    }

    init(metadata: LPLinkMetadata) {
        self.metadata = LinkPreviewMetadata.enriched(with: metadata)
    }

    var body: some View {
        LinkViewRepresentable(metadata: metadata)
            .frame(height: Self.pillHeight)
    }

}
