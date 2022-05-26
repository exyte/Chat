//
//  MediaPicker.swift.swift
//  Chat
//
//  Created by Alisa Mylnikova on 17.05.2022.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {

    var sourceType = UIImagePickerController.SourceType.camera

    @Binding var image: UIImage?
    @Binding var url: URL?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        // Part 1: File origin
        pickerController.sourceType = sourceType

        // Must import `UniformTypeIdentifiers`
        // Part 2: Define if photo or/and video is going to be captured by camera
        pickerController.mediaTypes = [UTType.image.identifier, UTType.video.identifier]

        // Part 3: camera settings
        if sourceType == .camera {
//        pickerController.cameraCaptureMode = .photo // Default media type .photo vs .video
//        pickerController.cameraDevice = .rear // rear Vs front
//        pickerController.cameraFlashMode = .on // on, off Vs auto
        }
        // Part 4: User can optionally crop only a certain part of the image or video with iOS default tools
        pickerController.allowsEditing = true
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            // Check for the media type
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
            switch mediaType {
            case UTType.image.identifier:
                // Handle image selection result
                print("Selected media is image")
                if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    parent.image = editedImage
                }

                if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    parent.image = originalImage
                }
                
                if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    parent.url = url
                }

            case UTType.video.identifier:
                // Handle video selection result
                print("Selected media is video")
                let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as! URL

            default:
                print("Mismatched type: \(mediaType)")
            }

            picker.dismiss(animated: true, completion: nil)
        }
    }
}

class FooDemoImagePickerViewController: UIViewController {

    @IBAction func selectImageAction(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        // Part 1: File origin
        pickerController.sourceType = .camera

        // Must import `UniformTypeIdentifiers`
        // Part 2: Define if photo or/and video is going to be captured by camera
        pickerController.mediaTypes = [UTType.image.identifier, UTType.video.identifier]

        // Part 3: camera settings
        pickerController.cameraCaptureMode = .photo // Default media type .photo vs .video
        pickerController.cameraDevice = .rear // rear Vs front
        pickerController.cameraFlashMode = .on // on, off Vs auto
        // Part 4: User can optionally crop only a certain part of the image or video with iOS default tools
        pickerController.allowsEditing = true

        // Part 5: For callback of user selection / cancellation
        //pickerController.delegate = self

        // Part 6: Present the UIImagePickerViewController
        present(pickerController, animated: true, completion: nil)
    }
}
