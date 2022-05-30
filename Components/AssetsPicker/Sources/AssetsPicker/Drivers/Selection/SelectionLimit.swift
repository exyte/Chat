//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

struct AssetSelectionLimitKey: EnvironmentKey {
    static var defaultValue: Int = 10
}

extension EnvironmentValues {
    var assetSelectionLimit: Int {
        get { self[AssetSelectionLimitKey.self] }
        set { self[AssetSelectionLimitKey.self] = newValue }
    }
}

public extension View {
    func assetSelectionLimit(_ value: Int) -> some View {
        self.environment(\.assetSelectionLimit, value)
    }
}
