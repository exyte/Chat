//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

extension DateFormatter {
    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()
}
