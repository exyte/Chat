//
//  Created by Alex.M on 23.06.2022.
//

import SwiftUI
import ExyteChat
import ExyteMediaPicker

struct ContentView: View {
    
    @State private var theme: ExampleThemeState = .accent
    @State private var color = Color(.exampleBlue)
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Active chat example") {
                        if !theme.isAccent, #available(iOS 18.0, *) {
                            ChatExampleView(
                                viewModel: ChatExampleViewModel(interactor: MockChatInteractor(isActive: true))
                            )
                            .chatTheme(themeColor: color)
                        } else {
                            ChatExampleView(
                                viewModel: ChatExampleViewModel(interactor: MockChatInteractor(isActive: true))
                            )
                            .chatTheme(
                                accentColor: color,
                                images: theme.images
                            )
                        }
                    }
                    
                    NavigationLink("Simple chat example") {
                        if !theme.isAccent, #available(iOS 18.0, *) {
                            ChatExampleView(viewModel: ChatExampleViewModel())
                                .chatTheme(themeColor: color)
                        } else {
                            ChatExampleView(viewModel: ChatExampleViewModel())
                                .chatTheme(
                                    accentColor: color,
                                    images: theme.images
                                )
                        }
                    }
                } header: {
                    Text("Basic examples")
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
                background: ChatTheme.Images.Background(
                    portraitBackgroundLight: Image("chatBackgroundLight"),
                    portraitBackgroundDark: Image("chatBackgroundDark"),
                    landscapeBackgroundLight: Image("chatBackgroundLandscapeLight"),
                    landscapeBackgroundDark: Image("chatBackgroundLandscapeDark")
                )
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


