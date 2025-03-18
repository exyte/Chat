import Combine
import GiphyUISDK
import SwiftUI
import UIKit

// https://github.com/Giphy/giphy-ios-sdk/blob/main/Docs.md
public struct GiphyPicker: UIViewControllerRepresentable {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @Binding private var selectedMedia: GPHMedia?
    private let giphyConfig: GiphyConfiguration
    
    init(
        giphyConfig: GiphyConfiguration,
        selectedMedia: Binding<GPHMedia?>
    ) {
        self.giphyConfig = giphyConfig
        self._selectedMedia = selectedMedia
    }
    
    public func makeUIViewController(context: Context) -> GiphyViewController {
        let controller = GiphyViewController()
        controller.swiftUIEnabled = true
        controller.mediaTypeConfig = giphyConfig.mediaTypeConfig
        controller.dimBackground = giphyConfig.dimBackground
        controller.showConfirmationScreen = giphyConfig.showConfirmationScreen
        controller.shouldLocalizeSearch = giphyConfig.shouldLocalizeSearch
        controller.delegate = context.coordinator
        controller.navigationController?.isNavigationBarHidden = true
        controller.navigationController?.setNavigationBarHidden(true, animated: false)
        
        GiphyViewController.trayHeightMultiplier = 1.0
        
        controller.theme = GPHTheme(
            type: colorScheme == .light
            ? .lightBlur
            : .darkBlur
        )
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return GiphyPicker.Coordinator(parent: self, selectedMedia: $selectedMedia)
    }
    
    public class Coordinator: NSObject, GiphyDelegate, @unchecked Sendable {

        @Binding var selectedMedia: GPHMedia?
        
        var parent: GiphyPicker
        
        init(parent: GiphyPicker, selectedMedia: Binding<GPHMedia?>) {
            self.parent = parent
            self._selectedMedia = selectedMedia
        }
        
        public func didDismiss(controller: GiphyViewController?) {
            DispatchQueue.main.async {
                self.parent.dismiss()
            }
        }
        
        public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            
            DispatchQueue.main.async { [media] in
                self.selectedMedia = media
                self.parent.dismiss()
            }
        }
        
    }
}

extension GPHMedia: @retroactive @unchecked Sendable {

}
