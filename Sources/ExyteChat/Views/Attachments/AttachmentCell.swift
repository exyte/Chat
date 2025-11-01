//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

public struct AttachmentCell: View {

    @Environment(\.chatTheme) var theme

    let attachment: Attachment
    let size: CGSize
    let onTap: (_ attachment: Attachment, _ isCancel: Bool) -> Void

    public init(
        attachment: Attachment, size: CGSize,
        onTap: @escaping (_ attachment: Attachment, _ isCancel: Bool) -> Void
    ) {
        self.attachment = attachment
        self.size = size
        self.onTap = onTap
    }

    public var body: some View {
        Group {
            if attachment.type == .image {
                ZStack {
                    content
                    if let status = attachment.fullUploadStatus {
                        switch status {
                        case .inProgress(.none):         // uploading status handled but not percent, simply show progress view
                            uploadingOverlay(percent: nil)
                        case .inProgress(let percent?):  // full upload status handling with percent, shows progress view with percent
                            uploadingOverlay(percent: percent)
                        case .complete:
                            EmptyView()
                        case .cancelled:
                            cancelledOverlay
                        case .error:
                            errorOverlay
                        }
                    } else {  // upload status not handled assumes that content is uploaded before being sent to receiver
                        EmptyView()
                    }
                }
            } else if attachment.type == .video {
                ZStack {
                    content
                    if let status = attachment.fullUploadStatus {
                        switch status {
                        case .inProgress(.none):
                            uploadingOverlay(percent: nil)
                        case .inProgress(let percent?):
                            uploadingOverlay(percent: percent)
                        case .complete:
                            VStack {
                                Spacer()
                                theme.images.message.playVideo
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                Spacer()
                            }
                        case .cancelled:
                            cancelledOverlay
                        case .error:
                            errorOverlay
                        }
                    } else {
                        VStack {
                            Spacer()
                            theme.images.message.playVideo
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                            Spacer()
                        }
                    }
                }
            } else {
                content
                    .overlay {
                        Text("Unknown", bundle: .module)
                    }
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .simultaneousGesture(attachmentTapGesture)
    }

    @ViewBuilder
    private func uploadingOverlay(percent: Int?) -> some View {
        Color.white.opacity(0.8)
        theme.images.message.cancel
            .resizable()
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .black.opacity(0.4))
            .frame(width: 36, height: 36)
        VStack {
            HStack {
                Spacer()
                if let percent {
                    AttachmentUploadStatusCapsuleView(percent)
                        .padding(4)
                } else {
                    AttachmentUploadStatusCapsuleView()
                        .padding(4)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var cancelledOverlay: some View {
        Color.white.opacity(0.8)
        VStack {
            HStack {
                Spacer()
                theme.images.message.cancel
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.4))
                    .frame(width: 26, height: 26)
                    .padding(4)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        Color.white.opacity(0.8)
        VStack {
            HStack {
                Spacer()
                theme.images.message.error
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.4))
                    .frame(width: 26, height: 26)
                    .padding(4)
            }
            Spacer()
        }
    }

    private var attachmentTapGesture: AnyGesture<Void>? {
        if let status = attachment.fullUploadStatus {
            switch status {
            case .cancelled: return nil
            case .error: return nil
            case .inProgress(_): return AnyGesture(TapGesture().onEnded { onTap(attachment, true) })
            case .complete: return AnyGesture(TapGesture().onEnded { onTap(attachment, false) })
            }
        }

        // attachments are uploaded before displayed so show play button
        return AnyGesture(TapGesture().onEnded { onTap(attachment, false) })

    }

    var content: some View {
        AsyncImageView(attachment: attachment, size: size)
    }
}

struct AsyncImageView: View {

    @Environment(\.chatTheme) var theme

    let attachment: Attachment
    let size: CGSize

    var body: some View {
        CachedAsyncImage(
            url: attachment.thumbnail,
            cacheKey: attachment.thumbnailCacheKey
        ) { imageView in
            imageView
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        } placeholder: {
            ZStack {
                Rectangle()
                    .foregroundColor(theme.colors.inputBG)
                    .frame(width: size.width, height: size.height)
                ActivityIndicator(size: 30, showBackground: false)
            }
        }
    }
}
