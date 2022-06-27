//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Simple example") {
                    ExampleView(viewModel: SimpleExampleViewModel())
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationTitle("Chat examples")
    }
}
