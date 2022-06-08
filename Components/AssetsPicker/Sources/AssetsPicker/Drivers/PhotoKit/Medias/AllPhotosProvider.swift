//
//  Created by Alex.M on 09.06.2022.
//

import Foundation

import Foundation
import Photos
import Combine

final class AllPhotosProvider: MediasProviderProtocol {
    private var subject = CurrentValueSubject<[MediaModel], Never>([])
    private var subscriptions = Set<AnyCancellable>()
    
    private var changeNotifier = PhotoLibraryChangeNotifier()
    
    var medias: AnyPublisher<[MediaModel], Never> {
        subject.eraseToAnyPublisher()
    }
    
    init() {
        changeNotifier.notifier
            .sink { [weak self] in
                self?.reload()
            }
            .store(in: &subscriptions)
    }
    
    func reload() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = map(fetchResult: allPhotos)
        
        DispatchQueue.main.async { [weak self] in
            self?.subject.send(assets)
        }
    }
}
