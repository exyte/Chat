//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import SwiftUI

struct AttachmentsPages: View {

    @Environment(\.chatTheme) private var theme

    @StateObject var viewModel: AttachmentsPagesViewModel
    var onClose: () -> Void

    var body: some View {
        let closeGesture = DragGesture()
            .onChanged { viewModel.offset = closeSize(from: $0.translation) }
            .onEnded {
                withAnimation {
                    viewModel.offset = .zero
                }
                if $0.translation.height >= 100 {
                    onClose()
                }
            }

        ZStack {
            Color.black
                .opacity(max((200.0 - viewModel.offset.height) / 200.0, 0.5))
                .ignoresSafeArea()
            VStack {
                TabView(selection: $viewModel.index) {
                    ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                        AttachmentsPage(attachment: attachment)
                            .tag(index)
                            .frame(maxHeight: .infinity)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.showMinis.toggle()
                                }
                            }
                    }
                }
                .environmentObject(viewModel)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .overlay(alignment: .top) {
                if viewModel.showMinis {
                    Text("\(viewModel.index + 1)/\(viewModel.attachments.count)")
                        .foregroundColor(.white)
                }
            }
            .overlay(alignment: .topLeading) {
                Button(action: onClose) {
                    theme.images.mediaPicker.cross
                }
                .tint(.white)
                .padding(.leading, 20)
            }
            .offset(viewModel.offset)
            .gesture(closeGesture)

            VStack {
                Spacer()
                ScrollViewReader { proxy in
                    if viewModel.showMinis {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                                    AttachmentCell(attachment: attachment) { _ in
                                        withAnimation {
                                            viewModel.index = index
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .id(index)
                                }
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(viewModel.index)
                        }
                        .onChange(of: viewModel.index) { newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
            }
            .offset(viewModel.offset)
        }
    }
}

private extension AttachmentsPages {
    func closeSize(from size: CGSize) -> CGSize {
        CGSize(width: 0, height: max(size.height, 0))
    }
}
