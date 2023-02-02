//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Alex.M on 22.06.2022.
//

import SwiftUI
import MediaPicker

struct AttachmentsEditor: View {

    @Environment(\.chatTheme) private var theme

    @ObservedObject var viewModel: InputViewModel

    var assetsPickerLimit: Int

    var body: some View {
        VStack {
            MediaPicker(isPresented: $viewModel.showPicker, limit: assetsPickerLimit) { medias in
                viewModel.medias = medias
            }
            .selectionStyle(.count)
            .mediaPickerTheme(
                    main: .init(
                        background: theme.colors.mediaPickerBackground
                    ),
                    selection: .init(
//                        emptyTint: .white,
//                        emptyBackground: .black.opacity(0.25),
//                        selectedTint: Color("CustomPurple")
                    )
                )
//            AssetsPicker(openPicker: $viewModel.showPicker)
//                .assetsPicker(selectionStyle: .count)
//                .assetsSelectionLimit(Configuration.assetsPickerLimit)
//                .assetsPickerOnChange { medias in
//                    viewModel.medias = medias
//                }
//                .assetsPickerCompletion { _ in
//                    viewModel.send()
//                }

            InputView(
                text: $viewModel.text,
                style: .signature,
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
        AttachmentsEditor(viewModel: viewModel, assetsPickerLimit: 10)
    }
}
