//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectableView<Content>: View where Content: View {
    let selected: Int?
    let onSelect: () -> Void
    @ViewBuilder let content: () -> Content
    
    @Environment(\.assetSelectionStyle) private var assetSelectionStyle
    
    var body: some View {
        content()
            .overlay(
                Button {
                    onSelect()
                }
                label: {
                    SelectIndicatorView(index: selected)
                        .padding(2)
                },
                alignment: selectionAlignment
            )
    }
}

private extension SelectableView {
    var selectionAlignment: Alignment {
        switch assetSelectionStyle {
        case .checkmark:
            return .bottomTrailing
        case .count:
            return .topTrailing
        }
    }
}
