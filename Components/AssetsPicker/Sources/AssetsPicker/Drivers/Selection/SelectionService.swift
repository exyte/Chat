//
//  Created by Alex.M on 08.06.2022.
//

import Foundation
import SwiftUI

final class SelectionService: ObservableObject {
    var assetSelectionLimit: Int?

    @Published private(set) var selected: [MediaModel] = []

    var canSendSelected: Bool {
        !selected.isEmpty
    }

    func canSelect(media: MediaModel) -> Bool {
        selected.count < selectionLimit || selected.contains(media)
    }

    func onSelect(media: MediaModel) {
        if let index = selected.firstIndex(of: media) {
            selected.remove(at: index)
        } else {
            if selected.count < selectionLimit {
                selected.append(media)
            }
        }
    }

    func index(of media: MediaModel) -> Int? {
        selected.firstIndex(of: media)
    }

    func mapToMedia() -> [Media] {
        selected
            .compactMap {
                guard let type = $0.mediaType else {
                    return nil
                }
                return Media(source: .media($0), type: type)
            }
    }
}

private extension SelectionService {
    var selectionLimit: Int {
        assetSelectionLimit ?? 0
    }
}
