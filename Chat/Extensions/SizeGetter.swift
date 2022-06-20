//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import SwiftUI

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != self.size {
                        DispatchQueue.main.async {
                            self.size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

extension View {
    public func watchSize(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
}
