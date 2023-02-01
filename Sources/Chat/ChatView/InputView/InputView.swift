//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI

enum InputViewStyle {
    case message
    case signature

    var placeholder: String {
        switch self {
        case .message:
            return "Type a message..."
        case .signature:
            return "Add signature..."
        }
    }
}

extension InputView {
    enum Action {
        case attach
        case photo
        case send
    }
}

struct InputView: View {

    @Environment(\.chatTheme) private var theme

    @Binding var text: String

    let style: InputViewStyle
    let canSend: Bool
    let onAction: (Action) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            leftButton
            TextInputView(text: $text, style: style)
                .frame(minHeight: 48)
            rigthButton
        }
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(backgroundColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    var leftButton: some View {
        switch style {
        case .message:
            attachButton
        case .signature:
            addButton
        }
    }

    @ViewBuilder
    var rigthButton: some View {
        if canSend || style == .signature {
            sendButton
        } else {
            cameraButton
        }
    }

    var attachButton: some View {
        Button {
            onAction(.attach)
        } label: {
            theme.images.attachButton
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 12))
        }
        .tint(theme.colors.buttonBackground)
    }

    var addButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.addButton
                .resizable()
                .frame(width: 24, height: 24)
                .background {
                    Circle().fill(Color.white)
                }
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
        .tint(theme.colors.buttonBackground)
    }

    var cameraButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.cameraButton
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
        }
        .tint(theme.colors.buttonBackground)
    }

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.sendButton
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .background {
                    Circle().fill(Color.white)
                }
                .padding(8)
        }
        .tint(theme.colors.myMessage)
    }

    var backgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.inputLightContextBackground
        case .signature:
            return theme.colors.inputDarkContextBackground
        }
    }
}

struct InputView_Previews: PreviewProvider {
    private static var text = "I'm sorry about that. I had important things to do. Can we try tomorrow?"

    static var previews: some View {
        VStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack {
                    InputView(
                        text: .constant(text),
                        style: .message,
                        canSend: true,
                        onAction: { _ in }
                    )

                    InputView(
                        text: .constant(""),
                        style: .message,
                        canSend: false,
                        onAction: { _ in }
                    )
                }
            }

            ZStack {
                Color(hex: "1F1F1F").ignoresSafeArea()

                VStack {
                    InputView(
                        text: .constant(text),
                        style: .signature,
                        canSend: true,
                        onAction: { _ in }
                    )

                    InputView(
                        text: .constant(""),
                        style: .signature,
                        canSend: false,
                        onAction: { _ in }
                    )
                }
            }
        }
        .environmentObject(GlobalFocusState())
    }
}
