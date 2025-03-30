//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI
import ExyteMediaPicker

struct ContentView: View {
    
    @State private var isAccent: Bool = true
    @State private var color = Color(.exampleBlue)

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Active chat example") {
                        if !isAccent, #available(iOS 18.0, *) {
                            ChatExampleView(
                                viewModel: ChatExampleViewModel(interactor: MockChatInteractor(isActive: true)),
                                title: "Active chat example"
                            )
                            .chatTheme(themeColor: color)
                        } else {
                            ChatExampleView(
                                viewModel: ChatExampleViewModel(interactor: MockChatInteractor(isActive: true)),
                                title: "Active chat example"
                            )
                            .chatTheme(accentColor: color)
                        }
                    }
                    
                    NavigationLink("Simple chat example") {
                        if !isAccent, #available(iOS 18.0, *) {
                            ChatExampleView(title: "Simple example")
                                .chatTheme(themeColor: color)
                        } else {
                            ChatExampleView(title: "Simple example")
                                .chatTheme(accentColor: color)
                        }
                    }
                    
                    NavigationLink("Chat with Image Background") {
                        ChatExampleView(title: "Background Image")
                            .chatTheme(
                                accentColor: color,
                                images: .init(
                                    backgroundLight: Image("chatBackgroundLight"),
                                    backgroundDark: Image("chatBackgroundDark")
                                )
                            )
                    }

                    NavigationLink("Simple comments example") {
                        CommentsExampleView()
                            .chatTheme(.init(colors: .init(
                                inputSignatureBG: .white.opacity(0.5),
                                inputSignatureText: .black,
                                inputSignaturePlaceholderText: .black.opacity(0.7)
                            )))
                            .mediaPickerTheme(
                                main: .init(
                                    pickerText: .white,
                                    pickerBackground: Color(.examplePickerBg),
                                    fullscreenPhotoBackground: Color(.examplePickerBg)
                                ),
                                selection: .init(
                                    accent: Color(.exampleBlue)
                                )
                            )
                    }
                } header: {
                    Text("Basic examples")
                }
            }
            .navigationTitle("Chat examples")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if #available(iOS 18.0, *) {
                            Button(isAccent ? "Accent" : "Themed") {
                                isAccent.toggle()
                            }
                            ColorPicker("", selection: $color)
                        } else {
                            ColorPicker("Accent", selection: $color)
                        }
                    }
                    
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

/// An enum that lets us iterate through the different ChatTheme styles
enum ExampleThemeState: String {
    case accent
    case image
    
    @available(iOS 18, *)
    case themed
    
    var title:String {
        self.rawValue.capitalized
    }
    
    func next() -> ExampleThemeState {
        switch self {
        case .accent:
            if #available(iOS 18.0, *) {
                return .themed
            } else {
                return .image
            }
        case .themed:
            return .image
        case .image:
            return .accent
        }
    }
    
    var images: ChatTheme.Images {
        switch self {
        case .accent, .themed: return .init()
        case .image:
            return .init(
                backgroundLight: Image("chatBackgroundLight"),
                backgroundDark: Image("chatBackgroundDark")
            )
        }
    }
    
    var isAccent: Bool {
        if #available(iOS 18.0, *) {
            return self != .themed
        }
        return true
    }
}
