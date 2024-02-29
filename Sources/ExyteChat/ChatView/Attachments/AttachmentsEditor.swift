//
//  AttachmentsEditor.swift
//  Chat
//
//  Created by Alex.M on 22.06.2022.
//

import SwiftUI
import ExyteMediaPicker
import ActivityIndicatorView

struct AttachmentsEditor<InputViewContent: View>: View {

    typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent>.InputViewBuilderClosure

    @Environment(\.chatTheme) var theme
    @Environment(\.mediaPickerTheme) var pickerTheme

    @EnvironmentObject private var keyboardState: KeyboardState
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @ObservedObject var inputViewModel: InputViewModel

    var inputViewBuilder: InputViewBuilderClosure?
    var chatTitle: String?
    var messageUseMarkdown: Bool
    var orientationHandler: MediaPickerOrientationHandler
    var mediaPickerSelectionParameters: MediaPickerParameters?

    @State private var seletedMedias: [Media] = []
    @State private var currentFullscreenMedia: Media?

    var showingAlbums: Bool {
        inputViewModel.mediaPickerMode == .albums
    }

    var body: some View {
        ZStack {
            mediaPicker

            if inputViewModel.showActivityIndicator {
                ActivityIndicator()
            }
        }
    }

    var mediaPicker: some View {
        GeometryReader { g in
            MediaPicker(isPresented: $inputViewModel.showPicker) {
                seletedMedias = $0
                assembleSelectedMedia()
            } albumSelectionBuilder: { _, albumSelectionView, _ in
                VStack {
                    albumSelectionHeaderView
                        .padding(.top, g.safeAreaInsets.top)
                    albumSelectionView
                    Spacer()
                    inputView
                        .padding(.bottom, g.safeAreaInsets.bottom)
                }
                .background(pickerTheme.main.albumSelectionBackground)
                .ignoresSafeArea()
            } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
                VStack {
                    cameraSelectionHeaderView(cancelClosure: cancelClosure)
                        .padding(.top, g.safeAreaInsets.top)
                    cameraSelectionView
                    Spacer()
                    inputView
                        .padding(.bottom, g.safeAreaInsets.bottom)
                }
                .ignoresSafeArea()
            }
            .didPressCancelCamera {
                inputViewModel.showPicker = false
            }
            .currentFullscreenMedia($currentFullscreenMedia)
            .showLiveCameraCell()
            .setSelectionParameters(mediaPickerSelectionParameters)
            .pickerMode($inputViewModel.mediaPickerMode)
            .orientationHandler(orientationHandler)
            .padding(.top)
            .background(pickerTheme.main.albumSelectionBackground)
            .ignoresSafeArea(.all)
            .onChange(of: currentFullscreenMedia) { newValue in
                assembleSelectedMedia()
            }
            .onChange(of: inputViewModel.showPicker) { _ in
                if !seletedMedias.isEmpty {
                    assembleSelectedMedia()
                    inputViewModel.send()
                }
            }
        }
    }

    func assembleSelectedMedia() {
        if !seletedMedias.isEmpty {
            inputViewModel.attachments.medias = seletedMedias
        } else if let media = currentFullscreenMedia {
            inputViewModel.attachments.medias = [media]
        } else {
            inputViewModel.attachments.medias = []
        }
    }

    @ViewBuilder
    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder($inputViewModel.attachments.text, inputViewModel.attachments, inputViewModel.state, .signature, inputViewModel.inputViewAction()) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: UUID(),
                    style: .signature,
                    messageUseMarkdown: messageUseMarkdown
                )
            }
        }
    }

    var albumSelectionHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    seletedMedias = []
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
        .padding(.bottom, 5)
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
