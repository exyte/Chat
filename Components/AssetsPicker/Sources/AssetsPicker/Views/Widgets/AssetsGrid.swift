//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

public struct AssetsGrid<Data, Camera, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Camera: View, Content: View {
    public let data: Data
    public let camera: () -> Camera
    public let content: (Data.Element) -> Content
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0, alignment: .top)]
    }
    
    public init(_ data: Data, @ViewBuilder camera: @escaping () -> Camera, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.camera = camera
        self.content = content
    }

    public var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            camera()
            ForEach(data) { item in
                content(item)
            }
        }
    }
}
