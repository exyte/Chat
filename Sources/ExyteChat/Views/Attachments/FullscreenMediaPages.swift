//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import SwiftUI

struct FullscreenMediaPages: View {

    @Environment(\.chatTheme) private var theme

    @StateObject var viewModel: FullscreenMediaPagesViewModel
    var safeAreaInsets: EdgeInsets
    var showShareButton: Bool = true
    var onClose: () -> Void

    @State private var shareItem: ShareItem?
    @State private var isPreparingShare = false
    @State private var showMinis = true

    private var tintColor: Color {
        theme.colors.mainText
    }

    var body: some View {
        VStack(spacing: 0) {
            if showMinis {
                headerView
            }

            mediaPagerView

            if showMinis {
                minisView
            }
        }
        .background {
            theme.colors.mainBG.ignoresSafeArea()
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    var headerView: some View {
        ZStack {
            HStack {
                Button(action: onClose) {
                    theme.images.mediaPicker.cross
                        .imageScale(.large)
                        .padding(5)
                }
                .tint(tintColor)
                .padding(.leading, 10)

                Spacer()

                HStack(spacing: 20) {
                    if showShareButton {
                        if isPreparingShare {
                            ProgressView()
                                .tint(tintColor)
                                .frame(width: 24, height: 24)
                                .padding(5)
                        } else {
                            controlIcon(theme.images.fullscreenMedia.share) {
                                shareCurrentAttachment()
                            }
                        }
                    }
                }
                .foregroundColor(tintColor)
                .padding(.trailing, 10)
            }

            Text("\(viewModel.index + 1)/\(viewModel.attachments.count)")
                .foregroundColor(tintColor)
        }
        .padding(.top, safeAreaInsets.top)
        .padding(.bottom, 8)
    }

    var mediaPagerView: some View {
        TabView(selection: $viewModel.index) {
            ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                AttachmentsPage(attachment: attachment)
                    .tag(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environmentObject(viewModel)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onTapGesture {
            withAnimation {
                showMinis.toggle()
            }
        }
    }

    var minisView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 2) {
                    ForEach(viewModel.attachments
                        .filter { $0.fullUploadStatus == nil || $0.fullUploadStatus == .complete }
                        .enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                            AttachmentCell(attachment: attachment, size: CGSize(width: 100, height: 100)) { _,_ in
                                withAnimation {
                                    viewModel.index = index
                                }
                            }
                            .cornerRadius(4)
                            .clipped()
                            .id(index)
                            .overlay {
                                if viewModel.index == index {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(theme.colors.sendButtonBackground, lineWidth: 2)
                                }
                            }
                            .padding(.vertical, 1)
                        }
                }
                .padding([.top, .horizontal], 12)
            }
            .onAppear {
                proxy.scrollTo(viewModel.index)
            }
            .onChange(of: viewModel.index) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

private struct ShareItem: Identifiable {
    let url: URL
    var id: URL { url }
}

private extension FullscreenMediaPages {
    func controlIcon(_ image: Image, onTap: @escaping () -> Void) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }

    func shareCurrentAttachment() {
        guard !isPreparingShare else { return }
        let attachment = viewModel.attachments[viewModel.index]
        isPreparingShare = true
        Task {
            let url = await AttachmentSharing.prepareForSharing(attachment)
            await MainActor.run {
                isPreparingShare = false
                shareItem = url.map(ShareItem.init)
            }
        }
    }
}

private extension FullscreenMediaPages {
    func closeSize(from size: CGSize) -> CGSize {
        CGSize(width: 0, height: max(size.height, 0))
    }
}
