//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import SwiftUI

public typealias AssetsPickerCompletionClosure = ([Media]) -> Void

struct AssetsPickerCompletionKey: EnvironmentKey {
    static var defaultValue: AssetsPickerCompletionClosure? = nil
}

extension EnvironmentValues {
    var assetsPickerCompletion: AssetsPickerCompletionClosure? {
        get { self[AssetsPickerCompletionKey.self] }
        set { self[AssetsPickerCompletionKey.self] = newValue }
    }
}

public extension View {
    func assetsPickerCompletion(_ value: @escaping AssetsPickerCompletionClosure) -> some View {
        self.environment(\.assetsPickerCompletion, value)
    }
}
