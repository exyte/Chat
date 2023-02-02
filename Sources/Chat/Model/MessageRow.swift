//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

public enum PositionInGroup {
    case first
    case middle
    case last
    case single // the only message in its group
}

struct MessageRow: Equatable {
    let message: Message
    let positionInGroup: PositionInGroup
}
