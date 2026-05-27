//
//  Created by Alex.M on 30.06.2022.
//

import Foundation
import SwiftUI

public struct PaginationHandler {
    public enum TriggerType {
        /// when (messages.count - 1 - offset)-th message is displayed handleClosure will be called
        /// 0 means last message triggers handleClosure
        case cellIndex(_ offset: Int)
        /// when table's y offset hits this threshold handleClosure will be called
        case pixels(_ offset: CGFloat)
    }

    let triggerType: TriggerType
    let hasMoreToLoad: Bool
    let handleClosure: () async -> ()
    let loadingIndicatorBuilder: (()->AnyView)

    public init<V: View>(triggerType: TriggerType = .pixels(0), hasMoreToLoad: Bool = true, handleClosure: @escaping () async -> (), loadingIndicatorBuilder: @escaping ()->V = { EmptyView() }) {
        self.triggerType = triggerType
        self.hasMoreToLoad = hasMoreToLoad
        self.handleClosure = handleClosure
        self.loadingIndicatorBuilder = { AnyView(loadingIndicatorBuilder()) }
    }

    @available(*, deprecated, message: "use TriggerType init instead")
    public init<V: View>(offset: Int = 0, hasMoreToLoad: Bool = true, handleClosure: @escaping () async -> (), loadingIndicatorBuilder: @escaping ()->V = { EmptyView() }) {
        self.triggerType = .cellIndex(offset)
        self.hasMoreToLoad = hasMoreToLoad
        self.handleClosure = handleClosure
        self.loadingIndicatorBuilder = { AnyView(loadingIndicatorBuilder()) }
    }
}
