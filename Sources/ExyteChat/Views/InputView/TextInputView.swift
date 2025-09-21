//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // We use the non-zero height from the first view that reports a value.
        if value == 0 {
            value = nextValue()
        }
    }
}

struct TextInputView: View {
    
    @Environment(\.chatTheme) private var theme
    
//    @EnvironmentObject private var globalFocusState: GlobalFocusState
    
    @Binding var text: String
    @State var inputFieldId: UUID
    var style: InputViewStyle
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization
    
    @State private var calculatedHeight: CGFloat = 48
    
    var body: some View {
        ZStack {
            ChatTextInputView(text: $text, placeholder: "Enter text")
            //        TextField("", text: $text, prompt: Text(style == .message ? localization.inputPlaceholder : localization.signatureText)
            //            .foregroundColor(style == .message ? theme.colors.inputPlaceholderText : theme.colors.inputSignaturePlaceholderText), axis: .vertical)
            //            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
                .foregroundColor(style == .message ? theme.colors.inputText : theme.colors.inputSignatureText)
                .padding(.leading, !isMediaGiphyAvailable() ? 12 : 0)
                .frame(height: calculatedHeight)

            textForSizing
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 18)) // IMPORTANT: Must match the font in TextInputView
                .padding(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 10))
                .foregroundStyle(Color.red)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ViewHeightKey.self,
                            value: geometry.size.height
                        )
                    }
                )
                .hidden()
        }
        .onPreferenceChange(ViewHeightKey.self) { newHeight in
            // Update the calculated height, clamping it within min/max bounds.
            // Using DispatchQueue.main.async avoids potential state-modification warnings.
            DispatchQueue.main.async {
                let newHeightClamped = min(max(newHeight, 24), 300)
                if self.calculatedHeight != newHeightClamped {
                    self.calculatedHeight = newHeightClamped
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    private var textForSizing: Text {
        if text.isEmpty {
            return Text("Enter text")
        } else {
            // Appending a space ensures that the last line is never empty,
            // which can cause measurement issues.
            return Text(text + " ")
        }
    }
    
    private func isMediaGiphyAvailable() -> Bool {
        return availableInputs.contains(AvailableInputType.media)
        || availableInputs.contains(AvailableInputType.giphy)
    }
}

struct ChatTextInputView: UIViewRepresentable {
    
    // The binding to the string that this view should display and modify.
    @Binding var text: String
    
    // The placeholder text to show when the text view is empty.
    let placeholder: String
    
    // MARK: - UIViewRepresentable Conformance
    
    /// Creates the initial `UITextView` and configures its initial state.
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // --- Basic Configuration ---
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.font = .systemFont(ofSize: 18)
        textView.backgroundColor = .clear // Blend with SwiftUI background
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // The coordinator will act as the text view's delegate.
        textView.delegate = context.coordinator
        
        // --- Placeholder Logic ---
        // Set the initial text and color based on whether the binding has text.
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText // A system color for placeholders
        } else {
            textView.text = text
            textView.textColor = .label // A system color for primary text
        }
        
        return textView
    }
    
    /// Updates the `UITextView` when the SwiftUI state changes.
    func updateUIView(_ uiView: UITextView, context: Context) {
        // This function is called when the @Binding `text` changes from outside
        // (e.g., another part of your SwiftUI view modifies the state).
        // We need to make sure the UITextView reflects this change.
        
        // Only update if the text is different to avoid unnecessary redraws
        // and potential cursor jumping.
        if uiView.text != self.text && !(uiView.text == placeholder && self.text.isEmpty){
            uiView.text = self.text
            uiView.textColor = .label
        } else if text.isEmpty && !uiView.isFirstResponder {
            // If the binding is cleared programmatically and the view isn't focused,
            // show the placeholder.
            uiView.text = self.placeholder
            uiView.textColor = .placeholderText
        }
        
        DispatchQueue.main.async {
            uiView.invalidateIntrinsicContentSize()
        }
    }
    
    /// Creates the Coordinator instance that facilitates communication between the
    /// `UITextView` and our SwiftUI view.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// The Coordinator class is the bridge between UIKit's delegate pattern and SwiftUI.
    /// It handles events from the `UITextView`, like text changes or focus changes.
    class Coordinator: NSObject, UITextViewDelegate {
        
        var parent: ChatTextInputView
        
        init(_ parent: ChatTextInputView) {
            self.parent = parent
        }
        
        /// Called when the user begins editing the text.
        func textViewDidBeginEditing(_ textView: UITextView) {
            // If the text view is showing the placeholder, clear it and
            // set the text color to the normal color.
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        /// Called whenever the text in the `UITextView` changes.
        func textViewDidChange(_ textView: UITextView) {
            // Update the SwiftUI binding with the new text.
            // We check the color to ensure we are not accidentally saving
            // the placeholder text to our binding.
            if textView.textColor != .placeholderText {
                self.parent.text = textView.text
            }
            
            textView.invalidateIntrinsicContentSize()
        }
        
        /// Called when the user finishes editing.
        func textViewDidEndEditing(_ textView: UITextView) {
            // If the text view is empty after editing, restore the placeholder.
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
            }
        }
    }
}
