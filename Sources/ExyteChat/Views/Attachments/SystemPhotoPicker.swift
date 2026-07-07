//
//  SystemPhotoPicker.swift
//  Chat
//
//  Wraps PhotosUI's system photo picker so its results can flow into the
//  same Media / draft attachment pipeline as the built-in media picker.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation
import ExyteMediaPicker

struct SystemPhotoPickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    var selectionParameters: MediaPickerSelectionParameters
    var onSelect: ([Media]) -> Void

    @State private var selection: [PhotosPickerItem] = []

    private var matchingFilter: PHPickerFilter {
        switch selectionParameters.mediaType {
        case .photo: return .images
        case .video: return .videos
        case .photoAndVideo: return .any(of: [.images, .videos])
        }
    }

    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selection,
                maxSelectionCount: selectionParameters.selectionLimit,
                matching: matchingFilter
            )
            .onChange(of: selection) { _, newValue in
                guard !newValue.isEmpty else { return }
                let medias = newValue.map { Media(source: SystemPickerMediaModel(item: $0)) }
                selection = []
                onSelect(medias)
            }
    }
}

extension View {
    func systemPhotoPicker(
        isPresented: Binding<Bool>,
        selectionParameters: MediaPickerSelectionParameters,
        onSelect: @escaping ([Media]) -> Void
    ) -> some View {
        modifier(SystemPhotoPickerModifier(isPresented: isPresented, selectionParameters: selectionParameters, onSelect: onSelect))
    }
}

/// Copies the file backing a `PhotosPickerItem` selection to a temporary URL so it
/// can be read more than once (photo library provided URLs are only valid transiently).
private struct SystemPickerTransferFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .item) { file in
            SentTransferredFile(file.url)
        } importing: { received in
            let copy = URL.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(received.file.pathExtension)
            try? FileManager.default.removeItem(at: copy)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}

actor SystemPickerMediaModel: MediaModelProtocol {
    private let item: PhotosPickerItem
    nonisolated let mediaType: MediaType?
    private var cachedURL: URL?

    init(item: PhotosPickerItem) {
        self.item = item
        self.mediaType = Self.resolveMediaType(for: item)
    }

    var duration: CGFloat? {
        get async {
            guard mediaType == .video, let url = await resolvedURL() else { return nil }
            let asset = AVURLAsset(url: url)
            guard let duration = try? await asset.load(.duration) else { return nil }
            return CGFloat(CMTimeGetSeconds(duration))
        }
    }

    func getURL() async -> URL? {
        await resolvedURL()
    }

    func getThumbnailURL() async -> URL? {
        await resolvedURL()
    }

    func getData() async throws -> Data? {
        guard let url = await resolvedURL() else { return nil }
        return try Data(contentsOf: url)
    }

    func getThumbnailData() async -> Data? {
        guard let url = await resolvedURL() else { return nil }
        guard mediaType == .video else {
            return try? Data(contentsOf: url)
        }
        return await Self.videoThumbnailData(url: url)
    }

    private func resolvedURL() async -> URL? {
        if let cachedURL { return cachedURL }
        guard let file = try? await item.loadTransferable(type: SystemPickerTransferFile.self) else { return nil }
        cachedURL = file.url
        return file.url
    }

    private static func resolveMediaType(for item: PhotosPickerItem) -> MediaType? {
        if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
            return .video
        }
        if item.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) {
            return .image
        }
        return nil
    }

    private static func videoThumbnailData(url: URL) async -> Data? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let cgImage = try? await generator.image(at: .zero).image else { return nil }
        return UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8)
    }
}
