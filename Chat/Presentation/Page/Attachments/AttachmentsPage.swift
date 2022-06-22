//
//  Created by Alex.M on 20.06.2022.
//

import SwiftUI

struct AttachmentsPage: View {
    let attachment: any Attachment

    var body: some View {
        if attachment is ImageAttachment {
            AsyncImage(url: attachment.full) { imageView in
                imageView
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 100, minHeight: 100)
            }
            .frame(maxHeight: 200)
        } else if let attachment = attachment as? VideoAttachment {
            VideoView(
                viewModel: VideoViewModel(attachment: attachment)
            )
        } else {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
                .frame(maxHeight: 200)
                .overlay {
                    Text("Unknown")
                }
        }
    }
}

extension CGSize {
    func closeGesture() -> CGSize {
        CGSize(width: 0, height: max(height, 0))
    }
}

final class AttachmentsPagesViewModel: ObservableObject {
    @Published var showMinis = false
}

struct AttachmentsPages: View {
    var attachments: [any Attachment]
    @State var index: Int

    var onClose: () -> Void

    @State var offset: CGSize = .zero
    @StateObject var viewModel = AttachmentsPagesViewModel()

    var body: some View {
        let closeGesture = DragGesture()
            .onChanged { offset = $0.translation.closeGesture() }
            .onEnded {
                withAnimation {
                    offset = .zero
                }
                if $0.translation.height >= 100 {
                    onClose()
                }
            }

        ZStack {
            Color.black
                .opacity(max((200.0 - offset.height) / 200.0, 0.5))
                .ignoresSafeArea()
            VStack {
                TabView(selection: $index) {
                    ForEach(attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
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
            .offset(offset)
            .gesture(closeGesture)

            VStack {
                Spacer()
                ScrollViewReader { proxy in
                    if viewModel.showMinis {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                                    AttachmentCell(attachment: attachment)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .id(index)
                                        .onTapGesture {
                                            withAnimation {
                                                self.index = index
                                            }
                                        }
                                }
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(index)
                        }
                        .onChange(of: index) { newValue in
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                }
            }
            .offset(offset)
        }
    }
}

struct AttachmentsPages_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsPages(attachments: [], index: 0, onClose: {})
    }
}
