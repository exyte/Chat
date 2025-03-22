//
//  LinkPillView.swift
//  Chat
//
//  Created by Matthew Fennell on 05/03/2025.
//

import LinkPresentation
import SwiftUI

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

/// Apple do not provide a SwiftUI equivalent to LPLinkView.
/// Therefore: write a minimal wrapper to use it ergonomically in Swift.
private struct LinkPreviewView: View {

    let metadata: LinkPreviewMetadata

    var body: some View {
        LinkViewRepresentable(metadata: metadata)
    }

}

/// In our default chat view, link previews appear in the message itself.
/// Inside the message, there is limited space, and if multiple links are given, the default link preview design, with title, image, video etc takes up too much space.
/// Unfortunately, Apple does not let us customise the LPLinkView presentation (e.g. hiding the preview image), apart from modifying the view's size.
/// Therefore, create a small wrapper around LinkPreviewView, which presents the preview in a small "pill" form.
struct LinkPillView: View {

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
        LinkPreviewView(metadata: metadata)
            .frame(height: Self.pillHeight)
    }

}

#Preview {
    let url = URL(string: "https://example.org")!
    LinkPillView(url: url)
}
