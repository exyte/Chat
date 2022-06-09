//
// Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

public typealias AssetsPickerCompletionClosure = ([Media]) -> Void

@MainActor
final class AssetsPickerViewModel: ObservableObject {
    @Published var mode: AssetsPickerMode = .photos
    @Published var isSent = false
#if os(iOS)
    @Published var showCamera = false
    @Published var cameraImage: URL?
#endif

    private let watcher = PhotoLibraryChangePermissionWatcher()
    
    // MARK: Calculated property

    func openCamera() {
        self.showCamera = true
    }
}
