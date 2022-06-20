//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine

final class AttachmentsFullscreenState {
    typealias Value = Optional<any Attachment>

    var showFullscreen = CurrentValueSubject<Value, Never>(nil)
}
