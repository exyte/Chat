//
//  Recorder.swift
//  
//
//  Created by Alisa Mylnikova on 09.03.2023.
//

import Foundation
import AVFoundation

final class Recorder {

    // duration and waveform samples
    typealias ProgressHandler = (Double, [CGFloat]) -> Void

    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var audioTimer: Timer?

    private var soundSamples: [CGFloat] = []

    var isAllowedToRecordAudio: Bool {
        audioSession.recordPermission == .granted
    }

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    func startRecording(durationProgressHandler: @escaping ProgressHandler) -> URL? {
        if !isAllowedToRecordAudio {
            Task {
                let granted = await audioSession.requestRecordPermission()
                if granted {
                    return startRecordingInternal(durationProgressHandler)
                }
                return nil
            }
        } else {
            return startRecordingInternal(durationProgressHandler)
        }
        return nil
    }

    private func startRecordingInternal(_ durationProgressHandler: @escaping ProgressHandler) -> URL? {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        soundSamples = []
        let recordingUrl = FileManager.tempAudioFile

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            durationProgressHandler(0.0, [])
            audioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.onTimer(durationProgressHandler)
            }

            return recordingUrl
        } catch {
            stopRecording()
            return nil
        }
    }

    func onTimer(_ durationProgressHandler: @escaping ProgressHandler) {
        audioRecorder?.updateMeters()
        if let power = audioRecorder?.averagePower(forChannel: 0) {
            // power from 0 db (max) to -60 db (roughly min)
            let adjustedPower = 1 - (max(power, -60) / 60 * -1)
            soundSamples.append(CGFloat(adjustedPower))
        }
        if let time = audioRecorder?.currentTime {
            durationProgressHandler(time, soundSamples)
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        audioTimer?.invalidate()
        audioTimer = nil
    }
}

extension AVAudioSession {
    func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
