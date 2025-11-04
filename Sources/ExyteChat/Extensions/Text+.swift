//
//  Text+.swift
//  Chat
//
//  Created by ThanPD on 3/11/25.
//

import SwiftUI

extension Text {
    func setTextDefaultColor(color: UIColor? = .black, fontName: String, size: CGFloat) -> Text {
        foregroundColor(Color(uiColor: color ?? .black))
            .font(Font.custom(fontName, size: size))
    }
}
