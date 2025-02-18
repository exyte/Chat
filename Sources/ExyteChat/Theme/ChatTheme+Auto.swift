//
//  ChatTheme+Auto.swift
//
//
//  Created by btoms20 on 22.01.2025.
//

import SwiftUI

// MARK: Accent Color Theme, with default backgrounds

extension View {
    /// Creates and applies a `ChatTheme` to your `ChatView` based around the provided `accentColor`
    /// - Parameters:
    ///   - color: The main accent color of your `ChatView`
    public func chatTheme(accentColor: Color) -> some View {
        return self
            .chatTheme(ChatTheme(accentColor: accentColor))
    }
}

// MARK: iOS 18+ Auto Themes Based on Accent Color

extension View {
    /// Creates and applies a `ChatTheme` to your `ChatView` based around the provided `color`
    /// - Parameters:
    ///   - color: The main color of your `ChatView`
    ///   - background: The background color / style of your `ChatView`. The default is to mix the provided `color` with the systems default backgrounds.
    ///   - improveContrast: Attempts to improve message contrast by nudging the `color` towards a more neutral luminance value (lightening / darkening) and altering mix ratios throughout the theme (defaults to `true`)
    ///
    /// - Note: If you're using a custom color and you want the exact color to come through, try disabling `improveContrast` but be sure the text is still legible.
    /// - Note: By default, this method mixes your theme `color` into the `ChatView`'s default background, if you don't want this behavior, you can set `background` to one of `.systemDefault`, or `.static(Color)`.
    @available(iOS 18.0, *)
    public func chatTheme(themeColor ac: Color, background: ThemedBackgroundStyle = .mixedWithAccentColor(), improveContrast: Bool = true) -> some View {
        let accentColor:Color
        if improveContrast {
            let luminance = ac.luminance
            let mixinColor = luminance > 0.7 ? Color.black : Color.white
            let mixinAmount = abs(luminance - 0.5) * 0.4
            accentColor = improveContrast ? ac.mix(with: mixinColor, by: mixinAmount) : ac
        } else {
            accentColor = ac
        }
        return modifier(ThemedChatView(accentColor: accentColor, background: background, improveContrast: improveContrast))
    }
}

extension Color {
    var luminance:Double {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        /// https://en.wikipedia.org/wiki/Relative_luminance
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance
    }
}

@available(iOS 18.0, *)
public enum ThemedBackgroundStyle {
    /// The default system background color
    case systemDefault
    /// A static background color across both light and dark mode
    case `static`(Color)
    /// The default system background tinted with the accent color (defaults to a value of 0.2)
    case mixedWithAccentColor(byAmount:Double = 0.2)
    
    internal func getBackgroundColor(withAccent accentColor: Color, improveContrast: Bool) -> Color {
        switch self {
        case .systemDefault:
            return Color(UIColor.systemBackground)
        case .static(let color):
            return color
        case .mixedWithAccentColor(let amount):
            return Color(UIColor.systemBackground)
                .mix(with: Color(UIColor.secondarySystemBackground), by: improveContrast ? 0.85 : 0.0)
                .mix(with: accentColor, by: amount)
        }
    }
    
    internal func getFriendMessageColor(improveContrast:Bool) -> Color {
        switch self {
        case .systemDefault:
            return Color(UIColor.secondarySystemBackground)
        case .static:
            return Color(UIColor.secondarySystemBackground)
        case .mixedWithAccentColor:
            if improveContrast {
                return Color(UIColor.systemBackground).opacity(0.8)
            } else {
                return Color(UIColor.secondarySystemBackground).opacity(0.8)
            }
        }
    }
}

@available(iOS 18.0, *)
internal struct ThemedChatView: ViewModifier {
    var accentColor: Color
    var background: ThemedBackgroundStyle
    var improveContrast: Bool
    
    func body(content: Content) -> some View {
        let backgroundColor = background.getBackgroundColor(withAccent: accentColor, improveContrast: improveContrast)
        return content
            .chatTheme(ChatTheme(accentColor: accentColor, background: background, improveContrast: improveContrast))
            .mediaPickerTheme(
                .init(
                    main: .init(
                        text: .primary,
                        albumSelectionBackground: backgroundColor,
                        fullscreenPhotoBackground: backgroundColor
                    ),
                    selection: .init(
                        selectedTint: accentColor,
                        fullscreenTint: accentColor
                    )
                )
            )
    }
}
