//
//  Created by Alex.M on 31.05.2022.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var url: URL?
    @Binding var isShown: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func makeCoordinator() -> CameraCoordinatorProtocol {
        CameraCoordinator(url: $url, isShown: $isShown)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        /* Do nothing */
    }
}

protocol CameraCoordinatorProtocol: UINavigationControllerDelegate, UIImagePickerControllerDelegate {}

private class CameraCoordinator: NSObject, CameraCoordinatorProtocol {
    @Binding var url: URL?
    @Binding var isShown: Bool

    init(url: Binding<URL?>, isShown: Binding<Bool>) {
        _url = url
        _isShown = isShown
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            isShown = false
        }
        
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let data = uiImage.jpegData(compressionQuality: 0) {
            
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent("")
            let fileUrl = directory.appendingPathComponent("camera.image.0000").appendingPathExtension(for: .image)
            do {
                try data.write(to: fileUrl)
                self.url = fileUrl
            } catch let exception {
                debugPrint(exception)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}
