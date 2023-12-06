//
//  MessageMenu.swift
//  
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI
import FloatingButton
import enum FloatingButton.Alignment

public enum MessageMenuAction {
    case reply
}

struct MessageMenu<MainButton: View>: View {

    @Environment(\.chatTheme) private var theme

    @Binding var isShowingMenu: Bool
    @Binding var menuButtonsSize: CGSize
    var alignment: Alignment
    var leadingPadding: CGFloat
    var trailingPadding: CGFloat
    var mainButton: () -> MainButton
    var onAction: (MessageMenuAction) -> ()

    var body: some View {
        FloatingButton(mainButtonView: mainButton().allowsHitTesting(false), buttons: [
            menuButton(title: "Reply", icon: theme.images.messageMenu.reply, action: .reply)
        ], isOpen: $isShowingMenu)
        .straight()
        .mainZStackAlignment(.top)
        .initialOpacity(0)
        .direction(.bottom)
        .alignment(alignment)
        .spacing(2)
        .animation(.linear(duration: 0.2))
        .menuButtonsSize($menuButtonsSize)
    }

    func menuButton(title: String, icon: Image, action: MessageMenuAction) -> some View {
        HStack(spacing: 0) {
            if alignment == .left {
                Color.clear.viewSize(leadingPadding)
            }

            ZStack {
                theme.colors.friendMessage
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .opacity(0.5)
                    .cornerRadius(12)
                HStack {
                    Text(title)
                        .foregroundColor(theme.colors.textLightContext)
                    Spacer()
                    icon
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
            }
            .frame(width: 208)
            .fixedSize()
            .onTapGesture {
                onAction(action)
            }

            if alignment == .right {
                Color.clear.viewSize(trailingPadding)
            }
        }
    }
}
