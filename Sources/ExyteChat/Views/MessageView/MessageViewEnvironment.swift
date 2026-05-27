import SwiftUI

private struct ChatMessageTypeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ChatType = .conversation
}

private struct MessageCustomizationParamsEnvironmentKey: EnvironmentKey {
    static let defaultValue = MessageCustomizationParameters()
}

extension EnvironmentValues {
    var chatMessageType: ChatType {
        get { self[ChatMessageTypeEnvironmentKey.self] }
        set { self[ChatMessageTypeEnvironmentKey.self] = newValue }
    }

    var messageCustomizationParams: MessageCustomizationParameters {
        get { self[MessageCustomizationParamsEnvironmentKey.self] }
        set { self[MessageCustomizationParamsEnvironmentKey.self] = newValue }
    }
}
