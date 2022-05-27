//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AllPhotosView: View {
    @Binding var openPicker: Bool

    @Binding var photos: [UIImage]
    @Binding var selected: [Int]
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100), spacing: 0)]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if photos.isEmpty {
                        ProgressView()
                    } else {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(photos.enumerated().map({ $0 }), id: \.offset) { (offset, image) in
                                SelectableImage(
                                    image: image,
                                    selected: selected.firstIndex(of: offset) ?? nil) {
                                        if let index = selected.firstIndex(of: offset) {
                                            selected.remove(at: index)
                                        } else {
                                            selected.append(offset)
                                        }
                                }
                                .padding(2)
                                
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle("All photos")
            .navigationBarItems(
                leading: Button("Cancel") { openPicker = false }
            )
            .navigationBarItems(
                trailing: Button(sendTitle) {}
                    .disabled(selected.isEmpty)
            )
        }
    }
}

private extension AllPhotosView {
    var sendTitle: String {
        if selected.isEmpty {
            return "Send"
        } else {
            return "Send (\(selected.count))"
        }
    }
}

struct AllPhotoView_Preview: PreviewProvider {
    @State static var photos: [UIImage] = [
        UIImage(color: .red),
        UIImage(color: .blue),
        UIImage(color: .blue),
        UIImage(color: .blue),
        UIImage(color: .red),
        UIImage(color: .blue),
        UIImage(color: .green),
        UIImage(color: .green),
        UIImage(color: .magenta),
        UIImage(color: .blue),
        UIImage(color: .red),
        UIImage(color: .red),
    ]
    
    @State static var selectedPhotos: [Int] = []
    
    static var previews: some View {
        AllPhotosView(
            openPicker: .constant(true),
            photos: $photos,
            selected: $selectedPhotos
        )
    }
}
