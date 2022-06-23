//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

struct AttachmentsGrid: View {
    private let single: (any Attachment)?
    private let grid: [any Attachment]

    let onTap: (any Attachment) -> Void

    init(attachments: [any Attachment], onTap: @escaping (any Attachment) -> Void) {
        if attachments.count % 2 == 0 {
            single = nil
            grid = attachments
        } else {
            single = attachments.first
            grid = attachments.dropFirst().map { $0 }
        }
        self.onTap = onTap
    }

    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack {
            if let attachment = single {
                AttachmentCell(attachment: attachment)
                    .onTapGesture {
                        onTap(attachment)
                    }
            }
            if !grid.isEmpty {
                LazyVGrid(columns: columns) {
                    ForEach(grid, id: \.id) { attachment in
                        AttachmentCell(attachment: attachment)
                            .onTapGesture {
                                onTap(attachment)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#if DEBUG
struct AttachmentsGrid_Preview: PreviewProvider {
    private static let examples = [1, 2, 3, 5, 10]

    static var previews: some View {
        Group {
            ForEach(examples, id: \.self) { count in
                ScrollView {
                    AttachmentsGrid(attachments: .random(count: count), onTap: { _ in })
                        .padding()
                        .background(Color.white)
                }
            }
            .padding()
            .background(Color.secondary)
        }
    }
}

extension Array where Element == any Attachment {
    static func random(count: Int) -> [any Attachment] {
        return Swift.Array(repeating: 0, count: count)
            .map { _ in randomAttachment() }
    }

    private static func randomAttachment() -> any Attachment {
        if Int.random(in: 0...3) == 0 {
            return VideoAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
        } else {
            return ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
        }
    }
}
#endif
