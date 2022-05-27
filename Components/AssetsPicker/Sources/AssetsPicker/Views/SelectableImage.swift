//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableImage: View {
    let image: UIImage
    let selected: Int?
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    SelectIndicatorView(index: selected)
                        .padding(2),
                    alignment: .topTrailing
                )
        }
        .onTapGesture(perform: onTap)
    }
}
