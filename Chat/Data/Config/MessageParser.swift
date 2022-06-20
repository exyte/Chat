//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import SwiftUI

struct MessageUseMarkdownKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var messageUseMarkdown: Bool {
        get { self[MessageUseMarkdownKey.self] }
        set { self[MessageUseMarkdownKey.self] = newValue }
    }
}

public extension View {
    func chatMessageUseMarkdown() -> some View {
        self.environment(\.messageUseMarkdown, true)
    }
}
