//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import SwiftUI

public protocol MessageParser {
    func text(from message: String) -> Text
}

public class DefaultMessageParser: MessageParser {
    public func text(from message: String) -> Text {
        Text(message)
    }
}

struct MessageParserKey: EnvironmentKey {
    static var defaultValue: any MessageParser = DefaultMessageParser()
}

extension EnvironmentValues {
    var messageParser: any MessageParser {
        get { self[MessageParserKey.self] }
        set { self[MessageParserKey.self] = newValue }
    }
}

public extension View {
    func chatUseMessageParser(_ parser: any MessageParser) -> some View {
        self.environment(\.messageParser, parser)
    }
}
