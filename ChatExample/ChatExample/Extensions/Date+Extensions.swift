//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

extension Date {
    func randomTime() -> Date {
        let startOfDay = Calendar.current.startOfDay(for: self)
        let endOfDay = startOfDay.addingTimeInterval(86400)
        let maxSeconds = Int(min(Date(), endOfDay).timeIntervalSince(startOfDay))
        return startOfDay.addingTimeInterval(TimeInterval(Int.random(in: 0...max(0, maxSeconds))))
    }
}

@MainActor
class DateFormatting {
    static let agoFormatter = RelativeDateTimeFormatter()
}

extension Date {
    // 1 hour ago, 2 days ago...
    @MainActor func formatAgo() -> String {
        let result = DateFormatting.agoFormatter.localizedString(for: self, relativeTo: Date())
        if result.contains("second") {
            return "Just now"
        }
        return result
    }
}
