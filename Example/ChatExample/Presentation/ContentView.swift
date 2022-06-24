//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    Group {
                        Text("Examples will be removed")
                            .font(.title)
                        NavigationLink("Simple example") {
                            ExampleView(viewModel: SimpleExampleViewModel())
                        }
                        NavigationLink("Live update example") {
                            ExampleView(viewModel: LiveUpdateExampleViewModel())
                        }
                    }
                    .tint(.red)

                    Group {
                        Text("Work examples")
                            .font(.title)

                        NavigationLink("Support chat example") {
                            SupportChatView()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationViewStyle(.stack)
        .navigationTitle("Chat examples")
    }
}
