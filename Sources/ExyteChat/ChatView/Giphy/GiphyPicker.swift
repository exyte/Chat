import Combine
import GiphyUISDK
import SwiftUI
import UIKit

// https://github.com/Giphy/giphy-ios-sdk/blob/main/Docs.md
public struct GiphyPicker: UIViewControllerRepresentable {
    
    @Binding private var selectedMedia: GPHMedia?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
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
    
    public class Coordinator: NSObject, GiphyDelegate {
        
        @Binding var selectedMedia: GPHMedia?
        
        var parent: GiphyPicker
        
        init(parent: GiphyPicker, selectedMedia: Binding<GPHMedia?>) {
            self.parent = parent
            self._selectedMedia = selectedMedia
        }
        
        public func didDismiss(controller: GiphyViewController?) {
            self.parent.dismiss()
        }
        
        public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            
            DispatchQueue.main.async {
                let _ = Empty<Void, Never>()
                    .sink(
                        receiveCompletion: { _ in
                            self.selectedMedia = media
                        },
                        receiveValue: { _ in }
                    )
                
                self.parent.dismiss()
            }
        }
        
    }
}
