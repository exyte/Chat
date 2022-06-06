//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct PermissionsErrorView: View {
    let text: String
    let action: (() -> Void)?
    
    var body: some View {
        Group {
            if let action = action {
                Button {
                    action()
                } label: {
                    Text(text)
                }
            } else {
                Text(text)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(Color.red.opacity(0.6))
        .cornerRadius(5)
        .padding(.horizontal, 20)
    }
}
