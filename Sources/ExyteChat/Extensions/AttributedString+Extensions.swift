//
//  Created by Alex.M on 08.07.2022.
//

import SwiftUI
import UIKit

extension AttributedString {

    func width(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = toAttrString(font: font).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.width)
    }

    func toAttrString(font: UIFont) -> NSAttributedString {
        var str = self
        str.setAttributes(AttributeContainer([.font: font]))
        return NSAttributedString(str)
    }

    public func lastLineWidth(labelWidth: CGFloat, font: UIFont) -> CGFloat {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let attrString = toAttrString(font: font)
        let availableSize = CGSize(width: labelWidth, height: .infinity)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: availableSize)
        let textStorage = NSTextStorage(attributedString: attrString)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: attrString.length - 1)
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(
            forGlyphAt: lastGlyphIndex,
            effectiveRange: nil)

        return lastLineFragmentRect.maxX
    }

    func numberOfLines(labelWidth: CGFloat, font: UIFont) -> Int {
        let attrString = toAttrString(font: font)
        let availableSize = CGSize(width: labelWidth, height: .infinity)
        let textSize = attrString.boundingRect(with: availableSize, options: .usesLineFragmentOrigin, context: nil)
        let lineHeight = font.lineHeight
        return Int(ceil(textSize.height/lineHeight))
    }

}

public extension AttributedString {
    var urls: [URL] {
        runs[\.link].map { (link, range) in
            link?.absoluteURL
        }
        .compactMap { $0 }
    }
}
