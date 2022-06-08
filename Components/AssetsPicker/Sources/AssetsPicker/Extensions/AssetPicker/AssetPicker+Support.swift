//
//  Created by Alex.M on 07.06.2022.
//

import Foundation
import SwiftUI

extension View {
    func cameraSheet(isShow: Binding<Bool>, image: Binding<URL?>) -> some View {
        
#if targetEnvironment(simulator)
        self.sheet(isPresented: isShow) {
            CameraStubView(isShow: isShow)
        }
#elseif os(iOS)
        self.sheet(isPresented: isShow) {
            CameraView(url: image, isShown: isShow)
        }
#endif
    }
    
    func assetsPickerToolbar(mode: Binding<AssetsPickerMode>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: mode) {
                    ForEach(AssetsPickerMode.allCases) { mode in
                        Text(mode.name).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    func assetsPickerNavigationBar(mode: Binding<AssetsPickerMode>, close: @escaping () -> Void) -> some View {
        self
            .assetsPickerToolbar(mode: mode)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel", action: close)
            )
    }
}
