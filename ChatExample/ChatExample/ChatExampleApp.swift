//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI

@main
struct ChatExampleApp: App {

    init() {
        _ = MockChatData.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
