//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Simple example") {
                        SimpleExampleView()
                    }
                } header: {
                    Text("Basic examples")
                }
            }
            .navigationTitle("Chat examples")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}
