//
//  File.swift
//  
//
//  Created by Alexandra Afonasova on 12.01.2023.
//

import SwiftUI

public extension View {
    
    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }
    
}
