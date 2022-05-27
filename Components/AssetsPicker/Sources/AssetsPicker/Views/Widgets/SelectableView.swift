//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {
    let selected: Int?
    let onTap: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .onTapGesture(perform: onTap)
            .overlay(
                SelectIndicatorView(index: selected)
                    .padding(2),
                alignment: .topTrailing
            )
    }
}
