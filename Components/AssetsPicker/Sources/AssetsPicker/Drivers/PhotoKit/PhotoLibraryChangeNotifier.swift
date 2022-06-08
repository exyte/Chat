//
//  File.swift
//  
//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import Combine
import Photos

final class PhotoLibraryChangeNotifier: NSObject, PHPhotoLibraryChangeObserver {
    public var notifier: AnyPublisher<Void, Never> {
        shared.eraseToAnyPublisher()
    }
    private var subject = PassthroughSubject<Void, Never>()
    private lazy var shared = subject.share()
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        subject.send()
    }
}
