//
//  Created by Alex.M on 02.06.2022.
//

import SwiftUI
import UIKit
import PhotosUI

struct LimitedLibraryPickerProxyView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.async { [controller] in
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: controller)
            context.coordinator.trackCompletion(in: controller)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    class Coordinator: NSObject {
        private var isPresented: Binding<Bool>
        
        init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
        }
        
        func trackCompletion(in controller: UIViewController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak controller] in
                if controller?.presentedViewController == nil {
                    self?.isPresented.wrappedValue = false
                } else if let controller = controller {
                    self?.trackCompletion(in: controller)
                }
            }
        }
    }
}
