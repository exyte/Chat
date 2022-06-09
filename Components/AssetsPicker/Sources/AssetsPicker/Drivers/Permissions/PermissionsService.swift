//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import Combine
import AVFoundation
import Photos

final class PermissionsService: ObservableObject {
    @Published var cameraAction: CameraAction?
    @Published var photoLibraryAction: PhotoLibraryAction?

    private var subscriptions = Set<AnyCancellable>()

    init() {
        photoLibraryChangePermissionPublisher
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
        reload()
    }

    func reload() {
        checkCameraAuthorizationStatus()
        checkPhotoLibraryAuthorizationStatus()
    }
}

private extension PermissionsService {
    func checkCameraAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        handle(camera: status)
    }

    func handle(camera status: AVAuthorizationStatus) {
        var result: CameraAction?
#if targetEnvironment(simulator)
        result = .unavailable
#else
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                self?.checkCameraAuthorizationStatus()
            }
        case .restricted:
            result = .unavailable
        case .denied:
            result = .authorize
        case .authorized:
            // Do nothing
            break
        @unknown default:
            result = .unknown
        }
#endif
        DispatchQueue.main.async { [weak self] in
            self?.cameraAction = result
        }
    }

    func checkPhotoLibraryAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        handle(photoLibrary: status)
    }

    func handle(photoLibrary status: PHAuthorizationStatus) {
        var result: PhotoLibraryAction?
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.handle(photoLibrary: status)
            }
        case .restricted:
            // TODO: Make sure what access can't change when status == .restricted
            result = .unavailable
        case .denied:
            result = .authorize
        case .authorized:
            // Do nothing
            break
        case .limited:
            result = .selectMore
        @unknown default:
            result = .unknown
        }

        DispatchQueue.main.async { [weak self] in
            self?.photoLibraryAction = result
        }
    }
}

extension PermissionsService {
    enum CameraAction {
        case authorize
        case unavailable
        case unknown
    }

    enum PhotoLibraryAction {
        case selectMore
        case authorize
        case unavailable
        case unknown
    }
}
