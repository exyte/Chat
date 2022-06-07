//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct CameraCell: View {
    let action: () -> Void
    
    @StateObject private var liveCameraViewModel = LiveCameraViewModel()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(uiImage: liveCameraViewModel.capturedImage)
                .resizable()
                .aspectRatio(1.0, contentMode: .fill)
                .overlay(
                    Image(systemName: "camera")
                        .foregroundColor(.white))
        }
    }
}
