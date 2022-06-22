//
//  Created by Alex.M on 30.05.2022.
//

import SwiftUI

public enum AssetsSelectionStyle {
    case checkmark
    case count
}

struct AssetsSelectionStyleKey: EnvironmentKey {
    static var defaultValue: AssetsSelectionStyle = .checkmark
}

extension EnvironmentValues {
    var assetsSelectionStyle: AssetsSelectionStyle {
        get { self[AssetsSelectionStyleKey.self] }
        set { self[AssetsSelectionStyleKey.self] = newValue }
    }
}

public extension View {
    func assetsPicker(selectionStyle: AssetsSelectionStyle) -> some View {
        self.environment(\.assetsSelectionStyle, selectionStyle)
    }
}
