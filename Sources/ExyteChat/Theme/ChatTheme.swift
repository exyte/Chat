//
//  ChatTheme.swift
//
//
//  Created by Alisa Mylnikova on 31.01.2023.
//

import SwiftUI

@MainActor
extension EnvironmentValues {
    @Entry var chatTheme = ChatTheme()
}

extension EnvironmentValues {
    @Entry var giphyConfig = GiphyConfiguration()
}

extension View {

    public func chatTheme(_ theme: ChatTheme) -> some View {
        self.environment(\.chatTheme, theme)
    }

    public func chatTheme(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init()
    ) -> some View {
        self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }

    public func giphyConfig(_ config: GiphyConfiguration) -> some View {
        self.environment(\.giphyConfig, config)
    }
}

public struct ChatTheme {
    public let colors: ChatTheme.Colors
    public let images: ChatTheme.Images
    public let style: ChatTheme.Style

    public init(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init(),
        style: ChatTheme.Style = .init()
    ) {
        self.style = style
        self.images = images
        
        // if background images have been set then override the mainBG color to be clear
        self.colors = if images.background != nil {
            ChatTheme.Colors(copy: colors, mainBG: .clear)
        } else {
            colors
        }
    }
    
    internal init(accentColor: Color, images: ChatTheme.Images) {
        self.init(
            colors: .init(
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyTimeText: Color.white.opacity(0.5),
                sendButtonBackground: accentColor
            ),
            images: images
        )
    }
    
    @available(iOS 18.0, *)
    internal init(accentColor: Color, background: ThemedBackgroundStyle = .mixedWithAccentColor(), improveContrast: Bool) {
        let backgroundColor: Color = background.getBackgroundColor(withAccent: accentColor, improveContrast: improveContrast)
        let friendMessageColor: Color = background.getFriendMessageColor(improveContrast: improveContrast, background: backgroundColor)
        self.init(
            colors: .init(
                mainBG: backgroundColor,
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyText: Color.white,
                messageMyTimeText: Color.white.opacity(0.5),
                messageFriendBG: friendMessageColor,
                inputBG: friendMessageColor,
                menuBG: backgroundColor,
                sendButtonBackground: accentColor
            )
        )
    }

    public struct Colors {
        public var mainBG: Color
        public var mainTint: Color
        public var mainText: Color
        public var mainCaptionText: Color

        public var messageMyBG: Color
        public var messageMyText: Color
        public var messageMyTimeText: Color

        public var messageFriendBG: Color
        public var messageFriendText: Color
        public var messageFriendTimeText: Color
        
        public var messageSystemBG: Color
        public var messageSystemText: Color
        public var messageSystemTimeText: Color

        public var inputBG: Color
        public var inputText: Color
        public var inputPlaceholderText: Color

        public var inputSignatureBG: Color
        public var inputSignatureText: Color
        public var inputSignaturePlaceholderText: Color

        public var menuBG: Color
        public var menuText: Color
        public var menuTextDelete: Color

        public var statusError: Color
        public var statusGray: Color

        public var sendButtonBackground: Color
        public var recordDot: Color

        public init(
            mainBG: Color = Color("mainBG", bundle: .current),
            mainTint: Color = Color("inputPlaceholderText", bundle: .current),
            mainText: Color = Color("mainText", bundle: .current),
            mainCaptionText: Color = Color("mainCaptionText", bundle: .current),
            messageMyBG: Color = Color("messageMyBG", bundle: .current),
            messageMyText: Color = Color.white,
            messageMyTimeText: Color = Color("messageMyTimeText", bundle: .current),
            messageFriendBG: Color = Color("messageFriendBG", bundle: .current),
            messageFriendText: Color = Color("mainText", bundle: .current),
            messageFriendTimeText: Color = Color("messageFriendTimeText", bundle: .current),
            messageSystemBG: Color = Color("messageFriendBG", bundle: .current),
            messageSystemText: Color = Color("mainText", bundle: .current),
            messageSystemTimeText: Color = Color("messageFriendTimeText", bundle: .current),
            inputBG: Color = Color("inputBG", bundle: .current),
            inputText: Color = Color("mainText", bundle: .current),
            inputPlaceholderText: Color = Color("inputPlaceholderText", bundle: .current),
            inputSignatureBG: Color = Color("inputBG", bundle: .current),
            inputSignatureText: Color = Color("mainText", bundle: .current),
            inputSignaturePlaceholderText: Color = Color("inputPlaceholderText", bundle: .current),
            menuBG: Color = Color("menuBG", bundle: .current),
            menuText: Color = Color("menuText", bundle: .current),
            menuTextDelete: Color = Color("menuTextDelete", bundle: .current),
            statusError: Color = Color("statusError", bundle: .current),
            statusGray: Color = Color("statusGray", bundle: .current),
            sendButtonBackground: Color = Color("messageMyBG", bundle: .current),
            recordDot: Color = Color("menuTextDelete", bundle: .current)
        ) {
            self.mainBG = mainBG
            self.mainTint = mainTint
            self.mainText = mainText
            self.mainCaptionText = mainCaptionText
            self.messageMyBG = messageMyBG
            self.messageMyText = messageMyText
            self.messageMyTimeText = messageMyTimeText
            self.messageFriendBG = messageFriendBG
            self.messageFriendText = messageFriendText
            self.messageFriendTimeText = messageFriendTimeText
            self.messageSystemBG = messageSystemBG
            self.messageSystemText = messageSystemText
            self.messageSystemTimeText = messageSystemTimeText
            self.inputBG = inputBG
            self.inputText = inputText
            self.inputPlaceholderText = inputPlaceholderText
            self.inputSignatureBG = inputSignatureBG
            self.inputSignatureText = inputSignatureText
            self.inputSignaturePlaceholderText = inputSignaturePlaceholderText
            self.menuBG = menuBG
            self.menuText = menuText
            self.menuTextDelete = menuTextDelete
            self.statusError = statusError
            self.statusGray = statusGray
            self.sendButtonBackground = sendButtonBackground
            self.recordDot = recordDot
        }
        
        public init(copy: Colors, mainBG: Color) {
            self.mainBG = mainBG
            self.mainTint = copy.mainTint
            self.mainText = copy.mainText
            self.mainCaptionText = copy.mainCaptionText
            self.messageMyBG = copy.messageMyBG
            self.messageMyText = copy.messageMyText
            self.messageMyTimeText = copy.messageMyTimeText
            self.messageFriendBG = copy.messageFriendBG
            self.messageFriendText = copy.messageFriendText
            self.messageFriendTimeText = copy.messageFriendTimeText
            self.messageSystemBG = copy.messageSystemBG
            self.messageSystemText = copy.messageSystemText
            self.messageSystemTimeText = copy.messageSystemTimeText
            self.inputBG = copy.inputBG
            self.inputText = copy.inputText
            self.inputPlaceholderText = copy.inputPlaceholderText
            self.inputSignatureBG = copy.inputSignatureBG
            self.inputSignatureText = copy.inputSignatureText
            self.inputSignaturePlaceholderText = copy.inputSignaturePlaceholderText
            self.menuBG = copy.menuBG
            self.menuText = copy.menuText
            self.menuTextDelete = copy.menuTextDelete
            self.statusError = copy.statusError
            self.statusGray = copy.statusGray
            self.sendButtonBackground = copy.sendButtonBackground
            self.recordDot = copy.recordDot
        }
    }

    public struct Images {
      
        public struct Background {
            
            let safeAreaRegions: SafeAreaRegions
            let safeAreaEdges: Edge.Set
            let portraitBackgroundLight: Image
            let portraitBackgroundDark: Image
            let landscapeBackgroundLight: Image
            let landscapeBackgroundDark: Image

            public init(
                safeAreaRegions: SafeAreaRegions = .all,
                safeAreaEdges: Edge.Set = .all,
                portraitBackgroundLight: Image,
                portraitBackgroundDark: Image,
                landscapeBackgroundLight: Image,
                landscapeBackgroundDark: Image
            ) {
                self.safeAreaRegions = safeAreaRegions
                self.safeAreaEdges = safeAreaEdges
                self.portraitBackgroundLight = portraitBackgroundLight
                self.portraitBackgroundDark = portraitBackgroundDark
                self.landscapeBackgroundLight = landscapeBackgroundLight
                self.landscapeBackgroundDark = landscapeBackgroundDark
            }
        }

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
            public var sticker: Image
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
      
        public var background: Background? = nil
  
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
            sticker: Image? = nil,
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
            scrollToBottom: Image? = nil,
            background: Background? = nil
        ) {
            self.backButton = backButton ?? Image("backArrow", bundle: .current)
            self.scrollToBottom = scrollToBottom ?? Image(systemName: "chevron.down")
            
            self.background = background

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
                sticker: sticker ?? Image("sticker", bundle: .current),
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
                cross: cross ?? Image(systemName: "xmark")
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
                pauseRecord: pauseRecord ?? Image(systemName: "pause.fill"),
                playRecord: playRecord ?? Image(systemName: "play.fill"),
                sendRecord: sendRecord ?? Image("sendRecord", bundle: .current),
                stopRecord: stopRecord ?? Image("stopRecord", bundle: .current)
            )

            self.reply = Reply(
                cancelReply: cancelReply ?? Image(systemName: "x.circle"),
                replyToMessage: replyToMessage ?? Image(systemName: "arrow.uturn.left")
            )
        }
    }
    
    public struct Style {
        public var replyOpacity: Double
        
        public init(replyOpacity: Double = 0.8) {
            self.replyOpacity = replyOpacity
        }
    }
}
