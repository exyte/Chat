//
//  Created by Alex.M on 17.06.2022.
//

import SwiftUI

public class MarkdownExampleMessageParser: MessageParser {
    public func text(from message: String) -> Text {
        guard let attributed = try? AttributedString(markdown: message) else {
            return Text(message)
        }
        return Text(attributed)
    }
}
