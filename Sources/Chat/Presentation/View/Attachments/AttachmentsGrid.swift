//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

struct AttachmentsGrid: View {
    private let single: (any Attachment)?
    private let grid: [any Attachment]
    private let hidden: String?

    let onTap: (any Attachment) -> Void

    init(attachments: [any Attachment], onTap: @escaping (any Attachment) -> Void) {
        if attachments.count > 4 {
            single = nil
            grid = attachments.prefix(4).map({ $0 })
            hidden = "+\(attachments.count - 3)"
        } else {
            if attachments.count % 2 == 0 {
                single = nil
                grid = attachments
            } else {
                single = attachments.first
                grid = attachments.dropFirst().map { $0 }
            }
            hidden = nil
        }
        self.onTap = onTap
    }

    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(spacing: 4) {
            if let attachment = single {
                AttachmentCell(attachment: attachment)
                    .frame(width: 204, height: grid.isEmpty ? 200 : 100)
                    .clipped()
                    .cornerRadius(12)
                    .onTapGesture {
                        onTap(attachment)
                    }
            }
            if !grid.isEmpty {
                ForEach(pair(), id: \.id) { pair in
                    HStack(spacing: 4) {
                        AttachmentCell(attachment: pair.left)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(12)
                            .onTapGesture {
                                onTap(pair.left)
                            }
                        AttachmentCell(attachment: pair.right)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .overlay {
                                if let hidden = hidden, pair.right.id == grid[3].id {
                                    ZStack {
                                        RadialGradient(
                                            colors: [
                                                .black.opacity(0.8),
                                                .black.opacity(0.6),
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 90
                                        )
                                        Text(hidden)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .cornerRadius(12)
                            .onTapGesture {
                                onTap(pair.right)
                            }
                    }
                }
            }
        }
    }
}

private extension AttachmentsGrid {
    func pair() -> Array<AttachmentsPair> {
        return stride(from: 0, to: grid.count - 1, by: 2)
            .map { AttachmentsPair(left: grid[$0], right: grid[$0+1]) }
    }
}

struct AttachmentsPair {
    let left: any Attachment
    let right: any Attachment

    var id: String {
        left.id + "+" + right.id
    }
}


#if DEBUG
struct AttachmentsGrid_Preview: PreviewProvider {
    private static let examples = [1, 2, 3, 4, 5, 10]

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
            return VideoAttachment.random()
        } else {
            return ImageAttachment.random()
        }
    }
}

extension ImageAttachment {
    static func random() -> ImageAttachment {
        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
    }
}

extension VideoAttachment {
    static func random() -> ImageAttachment {
        ImageAttachment(url: URL(string: "https://placeimg.com/640/480/sepia")!)
    }
}
#endif
