//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {
    
    @Environment(\.chatTheme) private var theme
    
    @EnvironmentObject private var globalFocusState: GlobalFocusState
    
    @Binding var text: String
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization
    
    private let defaultMaxCharacters: Int = 1000
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                HStack(spacing: -2) {
                    Text(" Ask Notica AI or tap")
                        .foregroundColor(Color(hex: "#3C3C43").opacity(0.6))
                        .font(Font.custom("PlusJakartaSans-Regular", size: UIDevice.current.userInterfaceIdiom == .pad ? 17 : 14))
                    
                    Image("ic_sparkle")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(hex: "#3C3C43").opacity(0.6))
                        .frame(width: 20, height: 20)
                }
            }
            
            TextField("", text: $text, axis: .vertical)
                .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
                .foregroundColor(.black)
                .tint(.black)
                .font(Font.custom("PlusJakartaSans-Regular", size: UIDevice.current.userInterfaceIdiom == .pad ? 19 : 16))
                .autocorrectionDisabled(true)
                .lineLimit(5)
                .simultaneousGesture(
                    TapGesture().onEnded {
                        globalFocusState.focus = .uuid(inputFieldId)
                    }
                )
                .onChange(of: text) { newValue in
                    if newValue.count > defaultMaxCharacters {
                        text = String(newValue.prefix(defaultMaxCharacters))
                    }
                }
        }
    }
}

