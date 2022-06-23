//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import AssetsPicker

public struct DraftMessage {
    public let text: String
    public let attachments: [any Attachment]
    public let createdAt: Date
}
