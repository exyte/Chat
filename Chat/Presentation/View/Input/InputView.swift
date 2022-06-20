//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import AssetsPicker

struct InputView: View {
    @ObservedObject var viewModel: InputViewModel

    @State private var isOpenPicker = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.updateText()
                    isOpenPicker = true
                } label: {
                    Text("Pick")
                }

                TextInputView(text: viewModel.showMedias ? .constant("") : $viewModel.text)

                Button {
                    viewModel.send()
                } label: {
                    Text("Send")
                }
            }
            .padding(5)
        }
        .background(Colors.background)
        .sheet(isPresented: $isOpenPicker) {
            AssetsPicker(openPicker: $isOpenPicker) { medias in
                viewModel.onSelect(medias: medias)
            }
            .countAssetSelection()
            .assetSelectionLimit(Configuration.assetsPickerLimit)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    @StateObject private static var viewModel = InputViewModel(
        draftMessageService: DraftComposeState()
    )
    
    static var previews: some View {
        InputView(viewModel: viewModel)
    }
}
