//
//  InputView+AttachmentPreviews.swift
//  Chat
//

import SwiftUI
import ExyteMediaPicker

extension InputView {

    @ViewBuilder
    var viewOnTop: some View {
        if style == .message, photoPickerBackend == .system, !viewModel.attachments.medias.isEmpty {
            mediaAttachmentsPreview
        }
        if style == .message, !viewModel.attachments.documents.isEmpty {
            documentAttachmentsPreview
        }
        if style == .message, let staticLocation = viewModel.attachments.staticLocation {
            staticLocationAttachmentPreview(staticLocation)
        }
        if style == .message, let liveLocation = viewModel.attachments.liveLocation {
            liveLocationAttachmentPreview(liveLocation)
        }
        if let message = viewModel.attachments.replyMessage {
            VStack(spacing: 8) {
                Rectangle()
                    .foregroundColor(theme.colors.messageFriendBG)
                    .frame(height: 2)

                HStack {
                    theme.images.reply.replyToMessage
                    Capsule()
                        .foregroundColor(theme.colors.messageMyBG)
                        .frame(width: 2)
                    VStack(alignment: .leading) {
                        Text(localization.replyToText + " " + message.user.name)
                            .font(.caption2)
                            .foregroundColor(theme.colors.mainCaptionText)
                        if !message.attributedText.characters.isEmpty {
                            Text(message.attributedText)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundColor(theme.colors.mainText)
                        }
                    }
                    .padding(.vertical, 2)

                    Spacer()

                    if let first = message.attachments.first {
                        AsyncImageView(attachment: first, size: CGSize(width: 30, height: 30))
                            .viewSize(30)
                            .cornerRadius(4)
                            .padding(.trailing, 16)
                    }

                    if let _ = message.recording {
                        theme.images.inputView.microphone
                            .renderingMode(.template)
                            .foregroundColor(theme.colors.mainTint)
                    }

                    theme.images.reply.cancelReply
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.attachments.replyMessage = nil
                            }
                        }
                }
                .padding(.horizontal, 26)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    var mediaAttachmentsPreview: some View {
        horizontalAttachmentsPreviewScroll {
            ForEach(viewModel.attachments.medias) { media in
                MediaAttachmentThumbnail(media: media) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.attachments.medias.removeAll { $0.id == media.id }
                    }
                }
            }
        }
    }

    var documentAttachmentsPreview: some View {
        horizontalAttachmentsPreviewScroll {
            ForEach(viewModel.attachments.documents) { document in
                DocumentAttachmentThumbnail(document: document) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.attachments.documents.removeAll { $0.id == document.id }
                    }
                }
            }
        }
    }

    func horizontalAttachmentsPreviewScroll<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                content()
            }
            .padding(.top, 8)
            .padding(.horizontal, 26)
        }
    }

    func staticLocationAttachmentPreview(_ staticLocation: StaticLocation) -> some View {
        HStack(spacing: 8) {
            theme.images.attachMenu.location
                .renderingMode(.template)
                .foregroundColor(theme.colors.mainText)

            Text(String(format: "%.4f, %.4f", staticLocation.latitude, staticLocation.longitude))
                .font(.caption)
                .foregroundColor(theme.colors.mainText)
                .lineLimit(1)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.attachments.staticLocation = nil
                }
            } label: {
                theme.images.mediaPicker.cross
                    .resizable()
                    .viewSize(10)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 26)
        .padding(.top, 8)
    }

    func liveLocationAttachmentPreview(_ liveLocation: LiveLocation) -> some View {
        HStack(spacing: 8) {
            theme.images.attachMenu.location
                .renderingMode(.template)
                .foregroundColor(theme.colors.mainTint)

            Text(localization.liveLocationText)
                .font(.caption.weight(.semibold))
                .foregroundColor(theme.colors.mainTint)
                .lineLimit(1)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.attachments.liveLocation = nil
                }
            } label: {
                theme.images.mediaPicker.cross
                    .resizable()
                    .viewSize(10)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 26)
        .padding(.top, 8)
    }
}

// MARK: - Thumbnail views

private struct RemovableAttachmentThumbnail<Content: View>: View {
    @Environment(\.chatTheme) var theme
    @Environment(\.chatSize) var chatSize

    var onRemove: () -> Void
    @ViewBuilder var content: () -> Content

    private var thumbnailSize: CGFloat {
        chatSize.width / 5
    }

    var body: some View {
        content()
            .viewSize(thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    theme.images.mediaPicker.cross
                        .resizable()
                        .viewSize(10)
                        .padding(4)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .foregroundColor(.white)
                }
                .offset(x: 6, y: -6)
            }
    }
}

private struct MediaAttachmentThumbnail: View {
    @Environment(\.chatTheme) var theme

    var media: Media
    var onRemove: () -> Void

    @State private var thumbnail: UIImage?

    var body: some View {
        RemovableAttachmentThumbnail(onRemove: onRemove) {
            ZStack {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(theme.colors.messageFriendBG)
                }
                
                if media.type == .video {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
        }
        .task(id: media.id) {
            if let data = await media.getThumbnailData(), let image = UIImage(data: data) {
                thumbnail = image
            }
        }
    }
}

private struct DocumentAttachmentThumbnail: View {
    @Environment(\.chatTheme) var theme

    var document: DocumentItem
    var onRemove: () -> Void

    var body: some View {
        RemovableAttachmentThumbnail(onRemove: onRemove) {
            VStack(spacing: 4) {
                theme.images.message.attachedDocument
                    .resizable()
                    .scaledToFit()
                    .viewSize(28)

                Text(document.fileName)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.colors.mainText)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.messageFriendBG)
        }
    }
}
