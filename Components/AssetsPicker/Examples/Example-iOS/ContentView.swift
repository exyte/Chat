//
//  ContentView.swift
//  Example-iOS
//
//  Created by Alex.M on 26.05.2022.
//

import SwiftUI
import AssetsPicker

struct ContentView: View {
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            Button {
                showPicker = true
            } label: {
                Text("Show picker")
            }
        }
        .sheet(isPresented: $showPicker) {
            AssetPicker()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
