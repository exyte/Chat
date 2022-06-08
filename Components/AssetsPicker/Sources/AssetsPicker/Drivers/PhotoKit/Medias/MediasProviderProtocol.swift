//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine
import Photos

protocol MediasProviderProtocol {
    var medias: AnyPublisher<[MediaModel], Never> { get }
    
    func reload()
}

extension MediasProviderProtocol {
    func map(fetchResult: PHFetchResult<PHAsset>) -> [MediaModel] {
        var medias: [MediaModel] = []
        
        if fetchResult.count == 0 {
            return medias
        }
        
        for index in 0...(fetchResult.count - 1) {
            let asset = fetchResult[index]
            medias.append(MediaModel(source: asset))
        }
        return medias
    }
}
