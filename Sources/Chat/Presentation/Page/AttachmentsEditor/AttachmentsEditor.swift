//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Alex.M on 22.06.2022.
//

import SwiftUI
import AssetsPicker

struct AttachmentsEditor: View {
    @ObservedObject var viewModel: InputViewModel

    var body: some View {
        VStack {
            AssetsPicker(openPicker: $viewModel.showPicker)
                .assetsPicker(selectionStyle: .count)
                .assetsSelectionLimit(Configuration.assetsPickerLimit)
                .assetsPickerOnChange { medias in
                    viewModel.medias = medias
                }

            InputView(
                style: .signature,
                text: $viewModel.text,
                canSend: viewModel.canSend,
                onAction: {
                    switch $0 {
                    case .attach, .photo:
                        // TODO: Open camera
                        break
                    case .send:
                        viewModel.send()
                    }
                }
            )
        }
        .padding(.top)
    }
}

struct AttachmentsEditor_Previews: PreviewProvider {
    @StateObject private static var viewModel = InputViewModel()

    static var previews: some View {
        AttachmentsEditor(viewModel: viewModel)
    }
}
