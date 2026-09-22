//
//  InputView+Types.swift
//  Chat
//

import SwiftUI
import ExyteMediaPicker
import GiphyUISDK

public enum InputViewStyle: Sendable {
    case message
    case signature
}

public enum AudioRecordingMode: Sendable {
    /// Default: hold the mic button to record; slide up to lock into hands-free mode.
    case holdToRecord
    /// Tap the mic button once to start recording, tap the stop button to finish. No lock capsule.
    case tapToToggle
}

public enum InputViewAction: Sendable {
    case giphy
    case photo
    case add
    case camera
    case send

    case recordAudioHold
    case recordAudioTap
    case recordAudioLock
    case stopRecordAudio
    case deleteRecord
    case playRecord
    case pauseRecord
    case location
    case document

    case saveEdit
    case cancelEdit
}

public enum InputViewState: Sendable {
    case empty
    case hasTextOrMedia

    case waitingForRecordingPermission
    case isRecordingHold
    case isRecordingTap
    case hasRecording
    case playingRecording
    case pausedRecording

    case editing

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia, .hasRecording, .isRecordingTap, .playingRecording, .pausedRecording: return true
        default: return false
        }
    }
}

public enum AvailableInputType: Sendable {
    case text
    case media
    case giphy
    case document
    /// Enables sharing a single, fixed location.
    case staticLocation
    /// Enables sharing a live, continuously-updating location.
    case liveLocation
    case audio
}

public struct InputViewAttachments {
    var medias: [Media] = []
    var giphyMedia: GPHMedia?
    var documents: [DocumentItem] = []
    var staticLocation: StaticLocation?
    var liveLocation: LiveLocation?
    var recording: Recording?
    var replyMessage: ReplyMessage?
}
