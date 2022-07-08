//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import AssetsPicker

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
    let style: InputViewStyle

    @Binding var text: String
    let canSend: Bool
    var onAction: (Action) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            leftButton
            TextInputView(style: style, text: $text)
                .frame(minHeight: 48)
            rigthButton
        }
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(backgroundColor)
        }
        .padding(.horizontal, 12)
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
            Image(systemName: "paperclip")
                .resizable()
                .padding(4)
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
        .tint(Colors.button)
    }

    var addButton: some View {
        Button {
            onAction(.photo)
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .background {
                    Circle().fill(Color.white)
                }
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
        .tint(Colors.button)
    }

    var cameraButton: some View {
        Button {
            onAction(.photo)
        } label: {
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
        }
        .tint(Colors.button)
    }

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .background {
                    Circle().fill(Color.white)
                }
                .padding(8)
        }
        .tint(Colors.myMessage)
    }

    var backgroundColor: Color {
        switch style {
        case .message:
            return Colors.inputBackground
        case .signature:
            return Color(hex: "F2F3F5").opacity(0.12)
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
                        style: .message,
                        text: .constant(text),
                        canSend: true,
                        onAction: { _ in }
                    )

                    InputView(
                        style: .message,
                        text: .constant(""),
                        canSend: false,
                        onAction: { _ in }
                    )
                }
            }

            ZStack {
                Color(hex: "1F1F1F").ignoresSafeArea()

                VStack {
                    InputView(
                        style: .signature,
                        text: .constant(text),
                        canSend: true,
                        onAction: { _ in }
                    )

                    InputView(
                        style: .signature,
                        text: .constant(""),
                        canSend: false,
                        onAction: { _ in }
                    )
                }
            }
        }
        .environmentObject(GlobalFocusState())
    }
}
