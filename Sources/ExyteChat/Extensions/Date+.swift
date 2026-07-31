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

extension Date {
    func countdownText() -> String {
        let remaining = max(0, Int(timeIntervalSince(Date())))
        let minutes = remaining / 60
        let seconds = remaining % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%d:%02d:%02d", hours, mins, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    func secondsElapsed() -> Int {
        max(0, Int(Date().timeIntervalSince(self)))
    }
}
