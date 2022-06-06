//
//  Created by Alex.M on 06.06.2022.
//

import Foundation
import SwiftUI

struct PermissionsActionView: View {
    let action: Action
    
    @State private var showSheet = false
    
    var body: some View {
        ZStack {
            if showSheet {
                LimitedLibraryPicker(isPresented: $showSheet)
                    .frame(width: 1, height: 1)
            }
            
            switch action {
            case .library(let assetsLibraryAction):
                buildLibraryAction(assetsLibraryAction)
            case .camera(let cameraAction):
                buildCameraAction(cameraAction)
            }
        }
    }
}

private extension PermissionsActionView {
    @ViewBuilder
    func buildLibraryAction(_ action: AssetsLibraryAction) -> some View {
        switch action {
        case .selectMore:
            PermissionsErrorView(text: "Button 'select more assets'") {
                showSheet = true
            }
        case .authorize:
            goToSettingsButton(text: "Enable photo access in settings")
        case .unavailable:
            PermissionsErrorView(text: "Text about you can't grant access to Photos", action: nil)
        case .unknown:
            PermissionsErrorView(text: "Note about some changes in iOS SDK", action: nil)
        }
    }
    
    @ViewBuilder
    func buildCameraAction(_ action: CameraAction) -> some View {
        switch action {
        case .authorize:
            goToSettingsButton(text: "Enable camera access in settings")
        case .unavailable:
            PermissionsErrorView(text: "Text about you can't grant access to Camera", action: nil)
        case .unknown:
            PermissionsErrorView(text: "Note about some changes in iOS SDK", action: nil)
        }
    }
    
    func goToSettingsButton(text: String) -> some View {
        PermissionsErrorView(
            text: text,
            action: {
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        )
    }
}

extension PermissionsActionView {
    enum Action {
        case library(AssetsLibraryAction)
        case camera(CameraAction)
    }
}
