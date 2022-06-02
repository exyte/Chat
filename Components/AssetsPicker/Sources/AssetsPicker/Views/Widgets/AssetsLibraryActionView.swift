//
//  Created by Alex.M on 02.06.2022.
//

import SwiftUI

struct AssetsLibraryActionView: View {
    let action: AssetsLibraryAction
    
    @State private var showSheet = false
    
    var body: some View {
        content
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(Color.red.opacity(0.6))
        .cornerRadius(5)
        .padding(.horizontal, 20)
    }
}

private extension AssetsLibraryActionView {
    @ViewBuilder var content: some View {
        switch action {
        case .selectMore:
            ZStack {
                Button {
                    showSheet = true
                } label: {
                    Text("Button 'select more assets'")
                }
                if showSheet {
                    LimitedLibraryPicker(isPresented: $showSheet)
                        .frame(width: 1, height: 1)
                }
            }
        case .authorize:
            Button {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Button 'Go to settings'")
            }
        case .unavailable:
            Text("Text about you can't grant access to Photos")
        case .unknown:
            Text("Note about some changes in iOS SDK")
        }
    }
}

struct AssetsLibraryActionView_Preview: PreviewProvider {
    static var previews: some View {
        AssetsLibraryActionView(action: .selectMore)
    }
}
