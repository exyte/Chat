//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Alex.M on 22.06.2022.
//

import SwiftUI
import MediaPicker

struct AttachmentsEditor<InputViewContent: View>: View {

    typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent>.InputViewBuilderClosure

    @Environment(\.chatTheme) var theme
    @Environment(\.mediaPickerTheme) var pickerTheme

    @ObservedObject var inputViewModel: InputViewModel

    var inputViewBuilder: InputViewBuilderClosure?
    var assetsPickerLimit: Int
    var chatTitle: String?

    var showingAlbums: Bool {
        inputViewModel.mediaPickerMode == .albums
    }

    var body: some View {
        MediaPicker(isPresented: $inputViewModel.showPicker, limit: assetsPickerLimit) {
            inputViewModel.attachments.medias = $0
        } albumSelectionBuilder: { _, albumSelectionView in
            VStack {
                albumSelectionHeaderView
                albumSelectionView
                Spacer()
                inputView
            }
            .background(pickerTheme.main.albumSelectionBackground)
        } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
            VStack {
                cameraSelectionHeaderView(cancelClosure: cancelClosure)
                cameraSelectionView
                Spacer()
                inputView
            }
            .background(pickerTheme.main.albumSelectionBackground)
        }
        .showLiveCameraCell()
        .pickerMode($inputViewModel.mediaPickerMode)
        .padding(.top)
        .background(pickerTheme.main.albumSelectionBackground)
        .ignoresSafeArea(.all)
    }

    @ViewBuilder
    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder($inputViewModel.attachments.text, inputViewModel.attachments, inputViewModel.state, .signature, inputViewModel.inputViewAction())
            } else {
                InputView(
                    viewModel: inputViewModel,
                    style: .signature
                )
            }
        }
    }

    var albumSelectionHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    inputViewModel.showPicker = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }

            HStack {
                Text("Recents")
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(radians: showingAlbums ? .pi : 0))
            }
            .foregroundColor(.white)
            .onTapGesture {
                withAnimation {
                    inputViewModel.mediaPickerMode = showingAlbums ? .photos : .albums
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    func cameraSelectionHeaderView(cancelClosure: @escaping ()->()) -> some View {
        HStack {
            Button {
                cancelClosure()
            } label: {
                theme.images.mediaPicker.cross
            }
            .padding(.trailing, 30)

            if let chatTitle = chatTitle {
                theme.images.mediaPicker.chevronRight
                Text(chatTitle)
                    .font(.title3)
                    .foregroundColor(theme.colors.textMediaPicker)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
