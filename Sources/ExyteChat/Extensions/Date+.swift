//
//  Created by Alex.M on 04.07.2022.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    func isSameDay(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

extension Date {
    static let iso8601Date = Date.ISO8601FormatStyle.iso8601.year().month().day()
}
