//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import AssetsPicker

struct InputView: View {
    @ObservedObject var draftViewModel: DraftViewModel

    @State private var isOpenPicker = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isOpenPicker = true
                } label: {
                    Text("Pick")
                }

                TextInputView(text: draftViewModel.isShownAttachments ? .constant("") : $draftViewModel.text)

                Button {
                    draftViewModel.send()
                } label: {
                    Text("Send")
                }
            }
            .padding(5)
        }
        .background(Colors.background)
        .sheet(isPresented: $isOpenPicker) {
            AssetsPicker(openPicker: $isOpenPicker) { medias in
                draftViewModel.onSelect(medias: medias)
            }
            .countAssetSelection()
            .assetSelectionLimit(Configuration.assetsPickerLimit)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    @StateObject private static var draftViewModel = DraftViewModel()
    
    static var previews: some View {
        InputView(draftViewModel: draftViewModel)
    }
}
