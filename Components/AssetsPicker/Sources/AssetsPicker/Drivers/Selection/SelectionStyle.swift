//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

public enum AssetSelectionStyle {
    case checkmark
    case count
}

struct AssetSelectionStyleKey: EnvironmentKey {
    static var defaultValue: AssetSelectionStyle = .checkmark
}

extension EnvironmentValues {
    var assetSelectionStyle: AssetSelectionStyle {
        get { self[AssetSelectionStyleKey.self] }
        set { self[AssetSelectionStyleKey.self] = newValue }
    }
}

public extension View {
    func checkmarkAssetSelection() -> some View {
        self.environment(\.assetSelectionStyle, .checkmark)
    }

    func countAssetSelection() -> some View {
        self.environment(\.assetSelectionStyle, .count)
    }
}
