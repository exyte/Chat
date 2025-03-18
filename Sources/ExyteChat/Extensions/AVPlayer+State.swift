//
//  Created by Alex.M on 22.06.2022.
//

import Foundation
import AVKit

extension AVPlayer {
    nonisolated var isPlaying: Bool {
        rate != 0 && error == nil
    }
}
