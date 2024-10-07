//
//  MessageMenu.swift
//  
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI
import FloatingButton
import enum FloatingButton.Alignment

public protocol MessageMenuAction: Equatable, CaseIterable {
    func title() -> String
    func titleColor() -> Color?
    func icon() -> Image
    func showForCurrentUser() -> Bool
    func showForOtherUser() -> Bool
    func showForAdmin() -> Bool
}

public enum DefaultMessageMenuAction: MessageMenuAction {

    case reply
    case edit(saveClosure: (String)->Void)

    public func title() -> String {
        switch self {
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        }
    }
    
    public func titleColor() -> Color? {
        return nil
    }
    
    public func showForCurrentUser() -> Bool {
        true
    }
    
    public func showForOtherUser() -> Bool {
        true
    }
    
    public func showForAdmin() -> Bool {
        true
    }

    public func icon() -> Image {
        switch self {
        case .reply:
            Image(.reply)
        case .edit:
            Image(.edit)
        }
    }

    public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        if case .reply = lhs, case .reply = rhs {
            return true
        }
        if case .edit(_) = lhs, case .edit(_) = rhs {
            return true
        }
        return false
    }

    public static var allCases: [DefaultMessageMenuAction] = [
        .reply, .edit(saveClosure: {_ in})
    ]
}

struct MessageMenu<MainButton: View, ActionEnum: MessageMenuAction>: View {

    @Environment(\.chatTheme) private var theme

    @Binding var isShowingMenu: Bool
    @Binding var menuButtonsSize: CGSize
    var alignment: Alignment
    var leadingPadding: CGFloat
    var trailingPadding: CGFloat
    var isCurrentUser: Bool
    var isAdmin: Bool
    var needToShowReactionsView: Bool = false
    var reactions: [String]?
    var selectReactionAction: (String) -> ()
    var onAction: (ActionEnum) -> ()
    var mainButton: () -> MainButton

    var body: some View {
        VStack(spacing: 5) {
            if let reactions, needToShowReactionsView {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(reactions, id: \.self) { reaction in
                                    Text(reaction)
                                        .font(.system(size: 30))
                                        .onTapGesture {
                                            selectReactionAction(reaction)
                                        }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .padding(.horizontal, 30)
                    }
                    .padding(.horizontal, 40)
                    .frame(maxHeight: 50)
            }

            FloatingButton(
                mainButtonView: mainButton().allowsHitTesting(false),
                buttons: ActionEnum.allCases.filter({ isAdmin ? $0.showForAdmin() : isCurrentUser ? $0.showForCurrentUser() : $0.showForOtherUser()}).map {
                    menuButton(title: $0.title(), icon: $0.icon(), color: $0.titleColor(), action: $0)
                },
                isOpen: $isShowingMenu
            )
            .straight()
            //.mainZStackAlignment(.top)
            .initialOpacity(0)
            .direction(.bottom)
            .alignment(alignment)
            .spacing(2)
            .animation(.linear(duration: 0.2))
            .menuButtonsSize($menuButtonsSize)
        }
    }

    func menuButton(title: String, icon: Image, color: Color?, action: ActionEnum) -> some View {
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
                        .foregroundColor(color != nil ? color : theme.colors.textLightContext)
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
