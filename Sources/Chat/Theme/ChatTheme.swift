//
//  ChatTheme.swift
//  
//
//  Created by Alisa Mylnikova on 31.01.2023.
//

import SwiftUI

struct ChatThemeKey: EnvironmentKey {
    static var defaultValue: ChatTheme = ChatTheme()
}

extension EnvironmentValues {
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }
}

public extension View {
    func chatTheme(_ theme: ChatTheme) -> some View {
        self.environment(\.chatTheme, theme)
    }

    func chatTheme(colors: ChatTheme.Colors = .init(),
                   images: ChatTheme.Images = .init()) -> some View {
        self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }
}

public struct ChatTheme {
    public let colors: ChatTheme.Colors
    public let images: ChatTheme.Images

    public init(colors: ChatTheme.Colors = .init(),
                images: ChatTheme.Images = .init()) {
        self.colors = colors
        self.images = images
    }

    public struct Colors {
        public var grayStatus: Color
        public var errorStatus: Color

        public var inputLightContextBackground: Color
        public var inputDarkContextBackground: Color

        public var buttonBackground: Color
        public var addButtonBackground: Color
        public var sendButtonBackground: Color

        public var myMessage: Color
        public var friendMessage: Color

        public var textLightContext: Color
        public var textDarkContext: Color
        public var textMediaPicker: Color

        public init(
            grayStatus: Color = Color(hex: "AFB3B8"),
            errorStatus: Color = Color.red,
            inputLightContextBackground: Color = Color(hex: "F2F3F5"),
            inputDarkContextBackground: Color = Color(hex: "F2F3F5").opacity(0.12),
            buttonBackground: Color = Color(hex: "989EAC"),
            addButtonBackground: Color = Color(hex: "#4F5055"),
            sendButtonBackground: Color = Color(hex: "#4962FF"),
            myMessage: Color = Color(hex: "4962FF"),
            friendMessage: Color = Color(hex: "EBEDF0"),
            textLightContext: Color = Color.black,
            textDarkContext: Color = Color.white,
            textMediaPicker: Color = Color(hex: "818C99")
        ) {
            self.grayStatus = grayStatus
            self.errorStatus = errorStatus
            self.inputLightContextBackground = inputLightContextBackground
            self.inputDarkContextBackground = inputDarkContextBackground
            self.buttonBackground = buttonBackground
            self.addButtonBackground = addButtonBackground
            self.sendButtonBackground = sendButtonBackground
            self.myMessage = myMessage
            self.friendMessage = friendMessage
            self.textLightContext = textLightContext
            self.textDarkContext = textDarkContext
            self.textMediaPicker = textMediaPicker
        }
    }

    public struct Images {
        public var sendingStatus: Image
        public var sentStatus: Image
        public var errorStatus: Image
        public var attachButton: Image
        public var addButton: Image
        public var cameraButton: Image
        public var sendButton: Image
        public var backButton: Image
        public var removeButton: Image
        public var playCircleButton: Image
        public var pauseCircleButton: Image
        public var playButton: Image
        public var closeButton: Image
        public var chevronRight: Image

        public init(
            sendingStatus: Image = Image(systemName: "clock"),
            sentStatus: Image? = nil,
            errorStatus: Image = Image(systemName: "exclamationmark.octagon.fill"),
            attachButton: Image? = nil,
            addButton: Image? = nil,
            cameraButton: Image? = nil,
            sendButton: Image? = nil,
            backButton: Image? = nil,
            removeButton: Image = Image(systemName: "xmark"),
            playCircleButton: Image = Image(systemName: "play.circle.fill"),
            pauseCircleButton: Image = Image(systemName: "pause.circle.fill"),
            playButton: Image = Image(systemName: "play.fill"),
            closeButton: Image? = nil,
            chevronRight: Image? = nil
        ) {
            self.sendingStatus = sendingStatus
            self.sentStatus = sentStatus ?? Image("checkmarks", bundle: .current)
            self.errorStatus = errorStatus
            self.attachButton = attachButton ?? Image("attach", bundle: .current)
            self.addButton = addButton ?? Image("add", bundle: .current)
            self.cameraButton = cameraButton ?? Image("camera", bundle: .current)
            self.sendButton = sendButton ?? Image("arrowUp", bundle: .current)
            self.backButton = backButton ?? Image("backArrow", bundle: .current)
            self.removeButton = removeButton
            self.playCircleButton = playCircleButton
            self.pauseCircleButton = pauseCircleButton
            self.playButton = playButton
            self.closeButton = closeButton ?? Image("cross", bundle: .current)
            self.chevronRight = closeButton ?? Image("chevronRight", bundle: .current)
        }
    }
}
