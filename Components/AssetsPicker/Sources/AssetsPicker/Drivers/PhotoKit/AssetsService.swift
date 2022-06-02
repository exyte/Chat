//
//  Created by Alex.M on 26.05.2022.
//

import Foundation
import Photos

enum AssetsLibraryAction {
    case selectMore
    case authorize
    case unavailable
    case unknown
}

final class AssetsService: NSObject, ObservableObject {
    // MARK: - Public values
    // MARK: Injected (on init)
    let skipEmptyAlbums: Bool

    // MARK: Published
    @Published var photos: [MediaModel] = []
    @Published var albums: [AlbumModel] = []
    @Published var selectedMedias: [MediaModel] = []
    @Published var action: AssetsLibraryAction? = nil
    
    // MARK: Calculated property
    var pickedMedias: [Media] {
        selectedMedias.compactMap {
            guard let type = $0.mediaType else {
                return nil
            }
            return Media(source: .media($0), type: type)
        }
    }

    // MARK: - Private values
    var task: Task<Void, Never>?
    
    // MARK: - Object life cycle
    init(skipEmptyAlbums: Bool = false) {
        self.skipEmptyAlbums = skipEmptyAlbums
        super.init()
        validateAuthorizationStatus()
    }
    
    // MARK: - Public methods
    func fetchAll() {
        task?.cancel()
        task = Task {
            await fetchAllPhotos()
            await fetchAlbums()
        }
    }
    
    func fetchAllPhotos() async {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        let assets = await AssetUtils.medias(from: allPhotos)
        
        DispatchQueue.main.async { [assets] in
            self.photos = assets
        }
    }
    
    func fetchAlbums() async {
        var albums = await getSmartAlbums()
        albums += await getUserAlbums()
        DispatchQueue.main.async { [albums] in
            self.albums = albums
        }
    }
}

// MARK: - Support methods (private)
private extension AssetsService {
    func getSmartAlbums() async -> [AlbumModel] {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: smartAlbums)
    }
    
    func getUserAlbums() async -> [AlbumModel] {
        let userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        return await AssetUtils.albums(from: userCollections)
    }
    
    func validateAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        handle(status: status)
    }
    
    func handle(status: PHAuthorizationStatus) {
        var shouldRegisterAssetsLibraryWatcher = true
        switch status {
        case .notDetermined:
            shouldRegisterAssetsLibraryWatcher = false
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.handle(status: status)
            }
        case .restricted:
            // TODO: Make sure what access can't change when status == .restricted
            shouldRegisterAssetsLibraryWatcher = false
            action = .unavailable
        case .denied:
            action = .authorize
        case .authorized:
            fetchAll()
        case .limited:
            action = .selectMore
            fetchAll()
        @unknown default:
            action = .unknown
            fetchAll()
            // FIXME: Log "Not handled new PHAuthorizationStatus - \(status)"
        }
        if shouldRegisterAssetsLibraryWatcher {
            PHPhotoLibrary.shared().register(self)
        }
    }
}

// MARK: - extension PHPhotoLibraryChangeObserver
extension AssetsService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        fetchAll()
    }
}
