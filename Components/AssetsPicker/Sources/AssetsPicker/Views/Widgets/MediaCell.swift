//
//  File.swift
//  
//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct MediaCell: View {
    let media: MediaModel
#if os(iOS)
    @State private var image: UIImage?
#else
    // FIXME: Create preview for image/video for other platforms
#endif
    
    var body: some View {
        ZStack {
            Group {
#if os(iOS)
                ThumbnailView(asset: media.source, image: $image)
#else
                // FIXME: Create preview for image/video for other platforms
#endif
            }
            if let duration = media.source.formattedDuration {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top))
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(duration)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                            .padding(.bottom, 4)
                    }
                }
            }
        }
    }
}
