//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

extension Date {
    func randomTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.hour = Int.random(min: 0, max: 23)
        components.minute = Int.random(min: 0, max: 59)
        components.second = Int.random(min: 0, max: 59)

        return Calendar.current.date(from: components)!
    }
}
