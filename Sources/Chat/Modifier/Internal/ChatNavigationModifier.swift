//
//  File.swift
//  
//
//  Created by Alexandra Afonasova on 12.01.2023.
//

import SwiftUI
import CachedAsyncImage

struct ChatNavigationModifier: ViewModifier {
    
    let title: String
    let status: String?
    let cover: URL?
    
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden()
            .toolbar {
                backButton
                infoToolbarItem
            }
    }
    
    private var backButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image("backArrow", bundle: .current)
            }
        }
    }
    
    private var infoToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                if let url = cover {
                    CachedAsyncImage(url: url, urlCache: .imageCache) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Rectangle().fill(Colors.grayStatus)
                        }
                    }
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .fontWeight(.semibold)
                        .font(.headline)
                    if let status = status {
                        Text(status)
                            .font(.footnote)
                            .foregroundColor(Colors.grayStatus)
                    }
                }
                Spacer()
            }
            .padding(.leading, 10)
        }
    }
    
}
