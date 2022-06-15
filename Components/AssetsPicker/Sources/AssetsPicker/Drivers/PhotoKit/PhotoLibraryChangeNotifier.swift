//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import Combine
import Photos

let photoLibraryChangePermissionNotification = Notification.Name(rawValue: "PhotoLibraryChangePermissionNotification")

let photoLibraryChangePermissionPublisher = NotificationCenter.default
    .publisher(for: photoLibraryChangePermissionNotification)
    .map { _ in }
    .share()

final class PhotoLibraryChangePermissionWatcher: NSObject, PHPhotoLibraryChangeObserver {
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        NotificationCenter.default.post(
            name: photoLibraryChangePermissionNotification,
            object: nil)
    }
}
