//
//  Created by Alex.M on 09.06.2022.
//

import Foundation
import Combine

final class AlbumViewModel: ObservableObject {
    // MARK: - Values
    // MARK: Public
    @Published var title: String? = nil
    @Published var medias: [MediaModel] = []
    @Published var isLoading: Bool = false
    
    let mediasProvider: MediasProviderProtocol

    // MARK: Private
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Object life cycle
    init(title: String, mediasProvider: MediasProviderProtocol) {
        self.title = title
        self.mediasProvider = mediasProvider
    }
    
    init(mediasProvider: MediasProviderProtocol) {
        self.mediasProvider = mediasProvider
    }
    
    // MARK: - Public methods
    func onStart() {
        mediasProvider.medias
            .assign(to: \.medias, on: self)
            .store(in: &subscriptions)
        
        mediasProvider.reload()
    }
    
    func onStop() {
        subscriptions.cancelAll()
    }
}
