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
    var onTapAttach: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            if onTapAttach != nil {
                attachButton
            } else {
                attachButton
                    .hidden()
            }
            TextInputView(text: $viewModel.text)
            sendButton
                .disabled(!viewModel.isAvailableSend)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(Colors.background)
        .onChange(of: viewModel.text) { _ in
            viewModel.validateDraft()
        }
        .onChange(of: viewModel.medias) { _ in
            viewModel.validateDraft()
        }
        .onChange(of: viewModel.showPicker) { value in
            if !value {
                viewModel.medias = []
            }
            viewModel.validateDraft()
        }
    }

    var attachButton: some View {
        Button {
            onTapAttach?()
        } label: {
            Image(systemName: "paperclip.circle")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(8)
        }
    }

    var sendButton: some View {
        Button {
            viewModel.send()
        } label: {
            Image(systemName: "arrow.up.circle")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(8)
        }
    }
}

struct InputView_Previews: PreviewProvider {
    @StateObject private static var viewModel = InputViewModel()
    
    static var previews: some View {
        Group {
            InputView(viewModel: viewModel, onTapAttach: {})
            InputView(viewModel: viewModel, onTapAttach: nil)
        }
    }
}
