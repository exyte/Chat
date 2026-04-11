import SwiftUI

private struct ChatMessageTypeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ChatType = .conversation
}

private struct MessageCustomizationParamsEnvironmentKey: EnvironmentKey {
    static let defaultValue = MessageCustomizationParameters()
}

private struct TimeViewWidthBindingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<CGFloat> = .constant(0)
}

private struct IsDisplayingMessageMenuEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
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

    var timeViewWidthBinding: Binding<CGFloat> {
        get { self[TimeViewWidthBindingEnvironmentKey.self] }
        set { self[TimeViewWidthBindingEnvironmentKey.self] = newValue }
    }

    var isDisplayingMessageMenu: Bool {
        get { self[IsDisplayingMessageMenuEnvironmentKey.self] }
        set { self[IsDisplayingMessageMenuEnvironmentKey.self] = newValue }
    }
}
