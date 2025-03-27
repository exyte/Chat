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

/// PlaceholderOrEnrichedLinkPillView has two mutually exclusive cases - either displaying a placeholder, or enriched content.
/// To switch from one case to the other, you need to create a new view.
/// This is inconvenient for consumers since you have to keep track of whether the enriched metadata has loaded or not.
///
/// Therefore, this view manages this complexity, hiding the state of whether the enriched metadata is loaded or not.
/// Since this view is the only view generating link preview metadata, it also manages the cache.
struct LinkPillView: View {

    @State var metadata: LinkPreviewMetadata
    private static let cache = LinkMetadataCache()

    init(url: URL) {
        guard let cached = Self.cache.get(forURL: url) else {
            metadata = .placeholder(for: url)
            return
        }
        metadata = .enriched(with: cached)
    }

    private func fetchMetadata(for url: URL) async {
        let provider = LPMetadataProvider()
        let metadata = try? await provider.startFetchingMetadata(for: url)
        guard let metadata = metadata else {
            return
        }
        self.metadata = .enriched(with: metadata)
        Self.cache.insert(metadata, forURL: url)
    }

    var body: some View {
        // Use ZStack instead of Group as animation modifier doesn't work with Group.
        ZStack {
            switch metadata {
            case .placeholder(let url):
                PlaceholderOrEnrichedLinkPillView(url: url)
                    .task {
                        await fetchMetadata(for: url)
                    }
            case .enriched(let metadata):
                PlaceholderOrEnrichedLinkPillView(metadata: metadata)
            }
        }
        .animation(.default, value: metadata)
    }

}

#Preview {
    LinkPillView(url: URL(string: "https://example.org")!)
}
