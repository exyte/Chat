//
//  ShareSheet.swift
//  Chat
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum AttachmentSharing {
    /// Resolves a local, shareable file URL for an attachment, downloading it first if it's remote.
    static func prepareForSharing(_ attachment: Attachment) async -> URL? {
        if attachment.full.isFileURL {
            return attachment.full
        }

        do {
            let (tempURL, response) = try await URLSession.shared.download(from: attachment.full)
            let fileExtension = nonEmpty(response.suggestedFilename.map { ($0 as NSString).pathExtension })
                ?? nonEmpty(attachment.full.pathExtension)
                ?? (attachment.type == .video ? "mp4" : "jpg")

            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(fileExtension)
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            return destinationURL
        } catch {
            print("[AttachmentSharing] Failed to download attachment for sharing: \(error)")
            return nil
        }
    }

    /// Resolves local, shareable file URLs for multiple attachments, downloading remote ones concurrently.
    /// Attachments that fail to download are skipped.
    static func prepareForSharing(_ attachments: [Attachment]) async -> [URL] {
        await withTaskGroup(of: (Int, URL?).self) { group in
            for (index, attachment) in attachments.enumerated() {
                group.addTask {
                    (index, await prepareForSharing(attachment))
                }
            }
            var urlsByIndex = [Int: URL]()
            for await (index, url) in group {
                urlsByIndex[index] = url
            }
            return urlsByIndex.keys.sorted().compactMap { urlsByIndex[$0] }
        }
    }

    private static func nonEmpty(_ string: String?) -> String? {
        guard let string, !string.isEmpty else { return nil }
        return string
    }
}
