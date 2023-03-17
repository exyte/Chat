//
//  File.swift
//  
//
//  Created by Alisa Mylnikova on 09.03.2023.
//

import SwiftUI

extension View {
    func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    func circleBackground(_ color: Color) -> some View {
        self.background {
            Circle().fill(color)
        }
    }
}
