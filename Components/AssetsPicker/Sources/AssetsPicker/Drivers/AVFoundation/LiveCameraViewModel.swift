//
//  Created by Alex.M on 07.06.2022.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit.UIImage

/**
 Object with live camera preview. Use `captureImage: UIImage` publisher.
 
    Used solution (with adapt for new iOs version): https://medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a
*/
class LiveCameraViewModel: NSObject, ObservableObject {
    private let position = AVCaptureDevice.Position.back
    private let quality = AVCaptureSession.Preset.medium
    
    private let sessionQueue = DispatchQueue(label: "LiveCameraQueue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    
    @Published public var capturedImage: UIImage = UIImage()
    
    override init() {
        super.init()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    deinit {
        self.captureSession.stopRunning()
    }
    
    private func configureSession() {
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInDualCamera,
                .builtInDualWideCamera,
                .builtInTripleCamera,
                .builtInTelephotoCamera,
                .builtInTrueDepthCamera,
                .builtInUltraWideCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: position)
        return session.devices.first
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

extension LiveCameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = uiImage
        }
    }
}
