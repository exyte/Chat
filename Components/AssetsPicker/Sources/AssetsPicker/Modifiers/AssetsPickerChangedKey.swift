//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import SwiftUI

struct AssetsPickerOnChangeKey: EnvironmentKey {
    static var defaultValue: AssetsPickerCompletionClosure? = nil
}

extension EnvironmentValues {
    var assetsPickerOnChange: AssetsPickerCompletionClosure? {
        get { self[AssetsPickerOnChangeKey.self] }
        set { self[AssetsPickerOnChangeKey.self] = newValue }
    }
}

public extension View {
    func assetsPickerOnChange(_ value: @escaping AssetsPickerCompletionClosure) -> some View {
        self.environment(\.assetsPickerOnChange, value)
    }
}
