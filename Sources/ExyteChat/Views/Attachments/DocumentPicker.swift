//
//  DocumentPicker.swift
//  Chat
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {

    var onPick: ([DocumentItem]) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        controller.allowsMultipleSelection = true
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([DocumentItem]) -> Void

        init(onPick: @escaping ([DocumentItem]) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let items = urls.map { url -> DocumentItem in
                let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int
                return DocumentItem(url: url, fileName: url.lastPathComponent, fileSize: fileSize ?? nil)
            }
            onPick(items)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        }
    }
}
