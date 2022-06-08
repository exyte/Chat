//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct AssetsGrid<Data, Camera, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Camera: View, Content: View {
    let data: Data
    let camera: () -> Camera
    let content: (Data.Element) -> Content
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    init(_ data: Data, @ViewBuilder camera: @escaping () -> Camera, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.camera = camera
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            camera()
            ForEach(data) { item in
                content(item)
            }
        }
    }
}
