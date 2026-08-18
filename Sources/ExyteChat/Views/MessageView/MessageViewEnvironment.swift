import SwiftUI

private struct ChatMessageTypeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ChatType = .conversation
}

private struct MessageCustomizationParamsEnvironmentKey: EnvironmentKey {
    static let defaultValue = MessageCustomizationParameters()
}

private struct ChatSizeEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
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

    var chatSize: CGSize {
        get { self[ChatSizeEnvironmentKey.self] }
        set { self[ChatSizeEnvironmentKey.self] = newValue }
    }
}
