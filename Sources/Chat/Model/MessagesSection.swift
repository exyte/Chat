//
//  Created by Alex.M on 08.07.2022.
//

import Foundation

class MessagesSection: Equatable {

    let date: Date
    var rows: [MessageRow]

    init(date: Date, rows: [MessageRow]) {
        self.date = date
        self.rows = rows
    }

    var formattedDate: String {
        date.formatted(date: .complete, time: .omitted)
    }
    static func == (lhs: MessagesSection, rhs: MessagesSection) -> Bool {
        lhs.date == rhs.date && lhs.rows == rhs.rows
    }

}
