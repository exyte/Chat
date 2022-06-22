//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import Combine

final class AttachmentsPagesViewModel: ObservableObject {
    var attachments: [any Attachment]
    @Published var index: Int

    @Published var showMinis = false
    @Published var offset: CGSize = .zero

    init(attachments: [any Attachment], index: Int) {
        self.attachments = attachments
        self.index = index
    }
}
