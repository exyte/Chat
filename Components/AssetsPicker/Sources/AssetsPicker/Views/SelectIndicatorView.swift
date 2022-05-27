//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct SelectIndicatorView: View {
    let index: Int?
    
    var body: some View {
        Group {
            if let index = index {
                Image(systemName: "\(index + 1).circle.fill")
                    .resizable()
            } else {
                Image(systemName: "circle")
                    .resizable()
            }
        }
        .foregroundColor(.blue)
        .frame(width: 24, height: 24)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct SelectIndicatorView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            SelectIndicatorView(index: nil)
            SelectIndicatorView(index: 0)
            SelectIndicatorView(index: 1)
            SelectIndicatorView(index: 16)
            SelectIndicatorView(index: 49)
            SelectIndicatorView(index: 50)
                .padding(4)
                .background(Color.red)
        }
    }
}
