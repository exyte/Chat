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
                viewModel: viewModel,
                onTapAttach: nil
            )
        }
    }
}

struct AttachmentsEditor_Previews: PreviewProvider {
    @StateObject private static var viewModel = InputViewModel()

    static var previews: some View {
        AttachmentsEditor(viewModel: viewModel)
    }
}
