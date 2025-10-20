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
    
    typealias InputViewBuilderClosure = ChatView<EmptyView, InputViewContent, DefaultMessageMenuAction>.InputViewBuilderClosure
    
    @Environment(\.chatTheme) var theme
    @Environment(\.mediaPickerTheme) var mediaPickerTheme
    @Environment(\.mediaPickerThemeIsOverridden) var mediaPickerThemeIsOverridden

    @EnvironmentObject private var keyboardState: KeyboardState
    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @ObservedObject var inputViewModel: InputViewModel

    var inputViewBuilder: InputViewBuilderClosure?
    var chatTitle: String?
    var messageStyler: (String) -> AttributedString
    var orientationHandler: MediaPickerOrientationHandler
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var availableInputs: [AvailableInputType]
    var localization: ChatLocalization

    @State private var seleсtedMedias: [Media] = []
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
        Text("under construction")
//        GeometryReader { g in
//            MediaPicker(isPresented: $inputViewModel.showPicker) {
//                seleсtedMedias = $0
//                assembleSelectedMedia()
//            } albumSelectionBuilder: { _, albumSelectionView, _ in
//                VStack {
//                    albumSelectionHeaderView
//                        .padding(.top, g.safeAreaInsets.top)
//                    albumSelectionView
//                    Spacer()
//                    inputView
//                        .padding(.bottom, g.safeAreaInsets.bottom)
//                }
//                .background(mediaPickerTheme.main.pickerBackground.ignoresSafeArea())
//            } cameraSelectionBuilder: { _, cancelClosure, cameraSelectionView in
//                VStack {
//                    cameraSelectionView
//                        .overlay(alignment: .top) {
//                            cameraSelectionHeaderView(cancelClosure: cancelClosure)
//                                .padding(.top, 12)
//                        }
//                        .padding(.top, g.safeAreaInsets.top)
//                    Spacer()
//                    inputView
//                        .padding(.bottom, g.safeAreaInsets.bottom)
//                }
//                .background(mediaPickerTheme.main.pickerBackground.ignoresSafeArea())
//            }
//            .didPressCancelCamera {
//                inputViewModel.showPicker = false
//            }
//            .currentFullscreenMedia($currentFullscreenMedia)
//            .liveCameraCell(.small)
//            .setSelectionParameters(mediaPickerSelectionParameters)
//            .pickerMode($inputViewModel.mediaPickerMode)
//            .orientationHandler(orientationHandler)
//            .padding(.top)
//            .background(theme.colors.mainBG)
//            .ignoresSafeArea(.all)
//            .onChange(of: currentFullscreenMedia) {
//                assembleSelectedMedia()
//            }
//            .onChange(of: inputViewModel.showPicker) {
//                let showFullscreenPreview = mediaPickerSelectionParameters?.showFullscreenPreview ?? true
//                let selectionLimit = mediaPickerSelectionParameters?.selectionLimit ?? 1
//
//                if selectionLimit == 1 && !showFullscreenPreview {
//                    assembleSelectedMedia()
//                    inputViewModel.send()
//                }
//            }
//            .applyIf(!mediaPickerThemeIsOverridden) {
//                $0.mediaPickerTheme(
//                    main: .init(
//                        pickerText: theme.colors.mainText,
//                        pickerBackground: theme.colors.mainBG,
//                        fullscreenPhotoBackground: theme.colors.mainBG
//                    ),
//                    selection: .init(
//                        accent: theme.colors.sendButtonBackground
//                    )
//                )
//            }
//        }
    }

    func assembleSelectedMedia() {
        if !seleсtedMedias.isEmpty {
            inputViewModel.attachments.medias = seleсtedMedias
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
                inputViewBuilder(
                    $inputViewModel.text, inputViewModel.attachments, inputViewModel.state,
                    .signature, inputViewModel.inputViewAction()
                ) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: UUID(),
                    style: .signature,
                    availableInputs: availableInputs,
                    messageStyler: messageStyler,
                    localization: localization
                )
            }
        }
    }

    var albumSelectionHeaderView: some View {
        ZStack {
            HStack {
                Button {
                    seleсtedMedias = []
                    inputViewModel.showPicker = false
                } label: {
                    Text(localization.cancelButtonText)
                }

                Spacer()
            }

            HStack {
                Text(localization.recentToggleText)
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(radians: showingAlbums ? .pi : 0))
            }
            .onTapGesture {
                withAnimation {
                    inputViewModel.mediaPickerMode = showingAlbums ? .photos : .albums
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(mediaPickerTheme.main.pickerText)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }

    func cameraSelectionHeaderView(cancelClosure: @escaping ()->()) -> some View {
        HStack {
            Button(action: cancelClosure) {
                theme.images.mediaPicker.cross
                    .imageScale(.large)
            }
            .tint(mediaPickerTheme.main.pickerText)
            .padding(.trailing, 30)

            if let chatTitle = chatTitle {
                theme.images.mediaPicker.chevronRight
                Text(chatTitle)
                    .font(.title3)
                    .foregroundColor(mediaPickerTheme.main.pickerText)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}
