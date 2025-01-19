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

    /// Exyte Chat Blue
    public static let ChatBlue:Color = Color(hex: "#4962FF")
    
    public init(colors: ChatTheme.Colors = .init(),
                images: ChatTheme.Images = .init()) {
        self.colors = colors
        self.images = images
    }

    public struct Colors {
        public var grayStatus: Color
        public var errorStatus: Color
        
        /// Textfield background
        public var inputLightContextBackground: Color
        /// Input dark context background
        public var inputDarkContextBackground: Color

        /// Main ChatView background
        public var mainBackground: Color
        /// Textfeild text color
        public var buttonBackground: Color
        /// Add button background
        public var addButtonBackground: Color
        /// Send / Record button background
        public var sendButtonBackground: Color
        /// Long press message background
        public var messageMenuBackground: Color

        /// Senders message bubble color
        public var myMessage: Color
        /// Friends message text color
        public var friendMessage: Color

        /// Friends message text color
        public var textLightContext: Color
        /// Senders message text color
        public var textDarkContext: Color
        /// Text media picker
        public var textMediaPicker: Color

        /// Recording dot color
        public var recordDot: Color

        /// Senders message time text color
        public var myMessageTime: Color
        /// Friends message time text color
        public var friendMessageTime: Color
        
        /// Time capsule background color
        public var timeCapsuleBackground: Color
        /// Time capsule foreground color
        public var timeCapsuleForeground: Color

        public init(
            grayStatus: Color = Color(UIColor.systemGray2),
            errorStatus: Color = Color.red,
            inputLightContextBackground: Color = Color(UIColor.secondarySystemBackground),
            inputDarkContextBackground: Color = Color.primary.opacity(0.1),
            mainBackground: Color = Color(UIColor.systemBackground),
            buttonBackground: Color = Color(UIColor.secondaryLabel),
            addButtonBackground: Color = Color(hex: "#4F5055"),
            sendButtonBackground: Color = ChatTheme.ChatBlue,
            messageMenuBackground: Color = Color(UIColor.systemBackground),
            myMessage: Color = ChatTheme.ChatBlue,
            friendMessage: Color = Color(UIColor.secondarySystemBackground),
            textLightContext: Color = Color.primary,
            textDarkContext: Color = Color.white,
            textMediaPicker: Color = Color(UIColor.systemGray),
            recordDot: Color = Color(hex: "#F62121"),
            myMessageTime: Color = Color.white.opacity(0.4),
            friendMessageTime: Color = Color.primary.opacity(0.4),
            timeCapsuleBackground: Color = Color(UIColor.systemBackground),
            timeCapsuleForeground: Color = Color.secondary
        ) {
            self.grayStatus = grayStatus
            self.errorStatus = errorStatus
            self.inputLightContextBackground = inputLightContextBackground
            self.inputDarkContextBackground = inputDarkContextBackground
            self.mainBackground = mainBackground
            self.buttonBackground = buttonBackground
            self.addButtonBackground = addButtonBackground
            self.sendButtonBackground = sendButtonBackground
            self.messageMenuBackground = messageMenuBackground
            self.myMessage = myMessage
            self.friendMessage = friendMessage
            self.textLightContext = textLightContext
            self.textDarkContext = textDarkContext
            self.textMediaPicker = textMediaPicker
            self.recordDot = recordDot
            self.myMessageTime = myMessageTime
            self.friendMessageTime = friendMessageTime
            self.timeCapsuleBackground = timeCapsuleBackground
            self.timeCapsuleForeground = timeCapsuleForeground
        }
    }

    public struct Images {

        public struct AttachMenu {
            public var camera: Image
            public var contact: Image
            public var document: Image
            public var location: Image
            public var photo: Image
            public var pickDocument: Image
            public var pickLocation: Image
            public var pickPhoto: Image
        }

        public struct InputView {
            public var add: Image
            public var arrowSend: Image
            public var attach: Image
            public var attachCamera: Image
            public var microphone: Image
        }

        public struct FullscreenMedia {
            public var play: Image
            public var pause: Image
            public var mute: Image
            public var unmute: Image
        }

        public struct MediaPicker {
            public var chevronDown: Image
            public var chevronRight: Image
            public var cross: Image
        }

        public struct Message {
            public var attachedDocument: Image
            public var checkmarks: Image
            public var error: Image
            public var muteVideo: Image
            public var pauseAudio: Image
            public var pauseVideo: Image
            public var playAudio: Image
            public var playVideo: Image
            public var sending: Image
        }

        public struct MessageMenu {
            public var delete: Image
            public var edit: Image
            public var forward: Image
            public var retry: Image
            public var save: Image
            public var select: Image
        }

        public struct RecordAudio {
            public var cancelRecord: Image
            public var deleteRecord: Image
            public var lockRecord: Image
            public var pauseRecord: Image
            public var playRecord: Image
            public var sendRecord: Image
            public var stopRecord: Image
        }

        public struct Reply {
            public var cancelReply: Image
            public var replyToMessage: Image
        }

        public var backButton: Image
        public var scrollToBottom: Image

        public var attachMenu: AttachMenu
        public var inputView: InputView
        public var fullscreenMedia: FullscreenMedia
        public var mediaPicker: MediaPicker
        public var message: Message
        public var messageMenu: MessageMenu
        public var recordAudio: RecordAudio
        public var reply: Reply

        public init(
            camera: Image? = nil,
            contact: Image? = nil,
            document: Image? = nil,
            location: Image? = nil,
            photo: Image? = nil,
            pickDocument: Image? = nil,
            pickLocation: Image? = nil,
            pickPhoto: Image? = nil,
            add: Image? = nil,
            arrowSend: Image? = nil,
            attach: Image? = nil,
            attachCamera: Image? = nil,
            microphone: Image? = nil,
            fullscreenPlay: Image? = nil,
            fullscreenPause: Image? = nil,
            fullscreenMute: Image? = nil,
            fullscreenUnmute: Image? = nil,
            chevronDown: Image? = nil,
            chevronRight: Image? = nil,
            cross: Image? = nil,
            attachedDocument: Image? = nil,
            checkmarks: Image? = nil,
            error: Image? = nil,
            muteVideo: Image? = nil,
            pauseAudio: Image? = nil,
            pauseVideo: Image? = nil,
            playAudio: Image? = nil,
            playVideo: Image? = nil,
            sending: Image? = nil,
            delete: Image? = nil,
            edit: Image? = nil,
            forward: Image? = nil,
            retry: Image? = nil,
            save: Image? = nil,
            select: Image? = nil,
            cancelRecord: Image? = nil,
            deleteRecord: Image? = nil,
            lockRecord: Image? = nil,
            pauseRecord: Image? = nil,
            playRecord: Image? = nil,
            sendRecord: Image? = nil,
            stopRecord: Image? = nil,
            cancelReply: Image? = nil,
            replyToMessage: Image? = nil,
            backButton: Image? = nil,
            scrollToBottom: Image? = nil
        ) {
            self.backButton = backButton ?? Image(systemName: "arrow.backward")
            self.scrollToBottom = scrollToBottom ?? Image(systemName: "chevron.down")

            self.attachMenu = AttachMenu(
                camera: camera ?? Image("camera", bundle: .current),
                contact: contact ?? Image("contact", bundle: .current),
                document: document ?? Image("document", bundle: .current),
                location: location ?? Image("location", bundle: .current),
                photo: photo ?? Image("photo", bundle: .current),
                pickDocument: pickDocument ?? Image("pickDocument", bundle: .current),
                pickLocation: pickLocation ?? Image("pickLocation", bundle: .current),
                pickPhoto: pickPhoto ?? Image("pickPhoto", bundle: .current)
            )

            self.inputView = InputView(
                add: add ?? Image("add", bundle: .current),
                arrowSend: arrowSend ?? Image("arrowSend", bundle: .current),
                attach: attach ?? Image("attach", bundle: .current),
                attachCamera: attachCamera ?? Image("attachCamera", bundle: .current),
                microphone: microphone ?? Image("microphone", bundle: .current)
            )

            self.fullscreenMedia = FullscreenMedia(
                play: fullscreenPlay ?? Image(systemName: "play.fill"),
                pause: fullscreenPause ?? Image(systemName: "pause.fill"),
                mute: fullscreenMute ?? Image(systemName: "speaker.slash.fill"),
                unmute: fullscreenUnmute ?? Image(systemName: "speaker.fill")
            )

            self.mediaPicker = MediaPicker(
                chevronDown: chevronDown ?? Image("chevronDown", bundle: .current),
                chevronRight: chevronRight ?? Image("chevronRight", bundle: .current),
                cross: cross ?? Image("cross", bundle: .current)
            )

            self.message = Message(
                attachedDocument: attachedDocument ?? Image("attachedDocument", bundle: .current),
                checkmarks: checkmarks ?? Image("checkmarks", bundle: .current),
                error: error ?? Image("error", bundle: .current),
                muteVideo: muteVideo ?? Image("muteVideo", bundle: .current),
                pauseAudio: pauseAudio ?? Image("pauseAudio", bundle: .current),
                pauseVideo: pauseVideo ?? Image(systemName: "pause.circle.fill"),
                playAudio: playAudio ?? Image("playAudio", bundle: .current),
                playVideo: playVideo ?? Image(systemName: "play.circle.fill"),
                sending: sending ?? Image("sending", bundle: .current)
            )

            self.messageMenu = MessageMenu(
                delete: delete ?? Image("delete", bundle: .current),
                edit: edit ?? Image("edit", bundle: .current),
                forward: forward ?? Image("forward", bundle: .current),
                retry: retry ?? Image("retry", bundle: .current),
                save: save ?? Image("save", bundle: .current),
                select: select ?? Image("select", bundle: .current)
            )

            self.recordAudio = RecordAudio(
                cancelRecord: cancelRecord ?? Image("cancelRecord", bundle: .current),
                deleteRecord: deleteRecord ?? Image("deleteRecord", bundle: .current),
                lockRecord: lockRecord ?? Image("lockRecord", bundle: .current),
                pauseRecord: pauseRecord ?? Image("pauseRecord", bundle: .current),
                playRecord: playRecord ?? Image("playRecord", bundle: .current),
                sendRecord: sendRecord ?? Image("sendRecord", bundle: .current),
                stopRecord: stopRecord ?? Image("stopRecord", bundle: .current)
            )

            self.reply = Reply(
                cancelReply: cancelReply ?? Image("cancelReply", bundle: .current),
                replyToMessage: replyToMessage ?? Image("replyToMessage", bundle: .current)
            )
        }
    }
}
