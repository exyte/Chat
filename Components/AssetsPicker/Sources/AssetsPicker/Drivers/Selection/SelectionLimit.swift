//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AssetsSelectionLimitKey: EnvironmentKey {
    static var defaultValue: Int = 10
}

extension EnvironmentValues {
    var assetsSelectionLimit: Int {
        get { self[AssetsSelectionLimitKey.self] }
        set { self[AssetsSelectionLimitKey.self] = newValue }
    }
}

public extension View {
    func assetsSelectionLimit(_ value: Int) -> some View {
        self.environment(\.assetsSelectionLimit, value)
    }
}
