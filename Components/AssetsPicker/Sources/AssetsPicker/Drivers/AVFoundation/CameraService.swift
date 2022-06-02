//
//  File.swift
//  
//
//  Created by Alex.M on 02.06.2022.
//

import Foundation
import AVFoundation

enum CameraAction {
    case unavailable
    case unknown
}

class CameraService: ObservableObject {
    // MARK: - Public values
    // MARK: Injected (on init)
    
    // MARK: Published
    @Published var action: CameraAction? = nil
    
    init() {
        checkAuthorizationStatus()
    }
}

private extension CameraService {
    func checkAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        handle(status: status)
    }
    
    func handle(status: AVAuthorizationStatus) {
#if targetEnvironment(simulator)
        action = .unavailable
#else
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                self?.checkAuthorizationStatus()
            }
        case .restricted, .denied:
            action = .unavailable
        case .authorized:
            print("All right! Go shot yourself!")
        @unknown default:
            action = .unknown
        }
#endif
    }
}
