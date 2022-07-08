//
//  Created by Alex.M on 08.07.2022.
//

import Foundation
import SwiftUI

public struct ChatSizes {
    public let avatar: CGFloat

    public init(avatar: CGFloat = 32) {
        self.avatar = avatar
    }
}

struct ChatSizesKey: EnvironmentKey {
    static var defaultValue: ChatSizes = ChatSizes()
}

extension EnvironmentValues {
    var chatSizes: ChatSizes {
        get { self[ChatSizesKey.self] }
        set { self[ChatSizesKey.self] = newValue }
    }
}

public extension View {
    func chatSizes(_ sizes: ChatSizes) -> some View {
        self.environment(\.chatSizes, sizes)
    }
}
