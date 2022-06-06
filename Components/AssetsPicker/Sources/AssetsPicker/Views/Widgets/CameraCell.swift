//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct CameraCell: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Rectangle()
                .fill(.black)
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "camera")
                        .foregroundColor(.white))
        }
    }
}
