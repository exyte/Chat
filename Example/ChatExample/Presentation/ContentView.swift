//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                NavigationLink("Simple example") {
                    ExampleView(viewModel: SimpleExampleViewModel())
                }

                NavigationLink("Live update example") {
                    ExampleView(viewModel: LiveUpdateExampleViewModel())
                }
            }
            .padding()
        }
        .navigationViewStyle(.stack)
        .navigationTitle("Chat examples")
    }
}
