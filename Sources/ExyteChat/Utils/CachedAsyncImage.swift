//
//  Created by Aman Kumar on 26/08/25.
//

import SwiftUI
import Kingfisher

/// A view that asynchronously loads and displays an image using Kingfisher.
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// You can specify a custom cache key:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"), cacheKey: "custom-key")
///
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CachedAsyncImage<Content>: View where Content: View {

    @State private var phase: AsyncImagePhase

    private let url: URL?
    private let cacheKey: String?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    public var body: some View {
        content(phase)
            .task(id: url, load)
    }

    /// Loads and displays an image from the specified URL.
    public init(url: URL?, cacheKey: String? = nil, scale: CGFloat = 1) where Content == Image {
        self.init(url: url, cacheKey: cacheKey, scale: scale) { phase in
    #if os(macOS)
            phase.image ?? Image(nsImage: .init())
    #else
            phase.image ?? Image(uiImage: .init())
    #endif
        }
    }


    /// Loads and displays a modifiable image with placeholder.
    public init<I, P>(
        url: URL?,
        cacheKey: String? = nil,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: url, cacheKey: cacheKey, scale: scale) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }


    /// Loads and displays a modifiable image in phases.
    public init(
        url: URL?,
        cacheKey: String? = nil,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.cacheKey = cacheKey
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self._phase = State(wrappedValue: .empty)
    }

    @Sendable
    private func load() async {
        guard let url = url else {
            withAnimation(transaction.animation) { phase = .empty }
            return
        }

        let resource = KF.ImageResource(downloadURL: url, cacheKey: cacheKey)

        do {
            let image = try await withCheckedThrowingContinuation { continuation in
                KingfisherManager.shared.retrieveImage(
                    with: resource,
                    options: [
                        .cacheOriginalImage,
                        .scaleFactor(scale)
                    ]
                ) { result in
                    switch result {
                    case .success(let value):
                        print("[CachedAsyncImage] Loaded image from: \(value.cacheType)")
                        continuation.resume(returning: value.image)
                    case .failure(let error):
                        print("[CachedAsyncImage] Failed to load image: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }

            withAnimation(transaction.animation) {
                #if canImport(UIKit)
                phase = .success(Image(uiImage: image))
                #elseif canImport(AppKit)
                phase = .success(Image(nsImage: image))
                #else
                phase = .success(Image(uiImage: image)) // fallback for iOS-only targets
                #endif
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }
}