//
//  SwiftUIView.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//

import SwiftUI

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)

        return ceil(boundingBox.width)
    }
}

struct MessageTextView: View {
    let text: String?

//    @State private var datetimeOffset: CGFloat = 0

    @Environment(\.messageUseMarkdown) var messageUseMarkdown

    var body: some View {
        if let text = text, !text.isEmpty {
            textView(text)
                .font(.body)
//                .background {
//                    GeometryReader { proxy in
//                        Color.clear
//                            .onAppear {
//                                if proxy.size.width > 200 {
//                                    datetimeOffset = 26
//                                } else {
//                                    datetimeOffset = 0
//                                }
//                            }
//                    }
//                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
//                .padding(.bottom, datetimeOffset)
        }
    }

    @ViewBuilder
    private func textView(_ text: String) -> some View {
        if messageUseMarkdown,
           let attributed = try? AttributedString(markdown: text) {
            Text(attributed)
        } else {
            Text(text)
        }
    }
}

struct MessageTextView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTextView(text: "Hello world!")
    }
}
