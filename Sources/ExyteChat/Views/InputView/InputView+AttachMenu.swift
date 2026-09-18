//
//  InputView+AttachMenu.swift
//  Chat
//

import SwiftUI
import AnchoredPopup

private struct AttachMenuItem {
    let icon: Image
    let title: String
    let action: InputViewAction
}

private let attachMenuLeftMargin: CGFloat = 14
private let attachMenuGap: CGFloat = 16

extension InputView {

    fileprivate var attachMenuItems: [AttachMenuItem] {
        var items: [AttachMenuItem] = []
        if isMediaAvailable() {
            items.append(AttachMenuItem(icon: theme.images.inputView.attach, title: localization.attachMediaText, action: .photo))
            if photoPickerBackend == .system {
                items.append(AttachMenuItem(icon: theme.images.inputView.attachCamera, title: localization.attachCameraText, action: .camera))
            }
        }
        if isGiphyAvailable() {
            items.append(AttachMenuItem(icon: theme.images.inputView.sticker, title: localization.attachGifText, action: .giphy))
        }
        if isDocumentAvailable() {
            items.append(AttachMenuItem(icon: theme.images.attachMenu.document, title: localization.attachDocumentText, action: .document))
        }
        if isLocationAvailable() {
            items.append(AttachMenuItem(icon: theme.images.attachMenu.location, title: localization.attachLocationText, action: .location))
        }
        return items
    }

    @ViewBuilder
    var leftButton: some View {
        let items = attachMenuItems

        if items.count > 1 {
            attachMenuButton(items: items)
        } else if let item = items.first, item.action == .photo {
            menuButton(action: .photo, image: theme.images.inputView.attach)
        } else if let item = items.first, item.action == .giphy {
            menuButton(action: .giphy, image: theme.images.inputView.sticker)
        } else if let item = items.first, item.action == .document {
            menuButton(action: .document, image: theme.images.attachMenu.document)
        } else if let item = items.first, item.action == .location {
            menuButton(action: .location, image: theme.images.attachMenu.location)
        }
    }

    var attachMenuPopupId: String {
        "exyte-chat-attach-menu-\(inputFieldId)"
    }

    fileprivate func attachMenuContent(_ items: [AttachMenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                AttachMenuRow(icon: item.icon, title: item.title) {
                    onAction(item.action)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.colors.inputBG)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }

    fileprivate func attachMenuButton(items: [AttachMenuItem]) -> some View {
        theme.images.inputView.attach
            .viewSize(24)
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
            .useAsPopupAnchor(id: attachMenuPopupId) {
                attachMenuContent(items)
            } customize: {
                $0.position(.absolute(.bottomLeading, position: CGPoint(x: attachMenuLeftMargin, y: inputBarFrame.minY - attachMenuGap)))
                    .background(.none)
                    .closeOnTapOutside(true)
                    .animation(.default)
            }
    }

    func menuButton(action: InputViewAction, image: Image) -> some View {
        Button {
            onAction(action)
        } label: {
            image
                .resizable()
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
        }
    }
}

private struct AttachMenuRow: View {
    @Environment(\.chatTheme) var theme
    @Environment(\.anchoredPopupDismiss) var dismissPopup

    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
            dismissPopup?()
        } label: {
            HStack(spacing: 10) {
                icon
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .viewSize(20)
                    .foregroundColor(theme.colors.mainTint)
                Text(title)
                    .font(.callout)
                    .foregroundColor(theme.colors.mainText)
            }
            .padding(14, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
