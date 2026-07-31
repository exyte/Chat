//
//  FullscreenLocationView.swift
//  Chat
//

import SwiftUI
import MapKit

struct FullscreenLocationView: View {

    private enum Kind {
        case staticLocation(StaticLocation)
        case liveLocation(LiveLocation, isMine: Bool)
    }

    @Environment(\.chatTheme) var theme
    @Environment(\.chatLocalization) var localization

    var onStopSharing: () -> Void
    var onClose: () -> Void

    private var kind: Kind

    init(staticLocation: StaticLocation, onClose: @escaping () -> Void) {
        self.kind = .staticLocation(staticLocation)
        self.onStopSharing = {}
        self.onClose = onClose
    }

    init(liveLocation: LiveLocation, isMyLiveLocation: Bool, onStopSharing: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.kind = .liveLocation(liveLocation, isMine: isMyLiveLocation)
        self.onStopSharing = onStopSharing
        self.onClose = onClose
    }

    private var coordinate: CLLocationCoordinate2D {
        switch kind {
        case .staticLocation(let location): location.coordinate
        case .liveLocation(let liveLocation, _): liveLocation.coordinate
        }
    }

    private var isEnded: Bool {
        if case .liveLocation(let liveLocation, _) = kind { return liveLocation.isEnded }
        return false
    }

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: .constant(.region(.closeUp(around: coordinate)))) {
                Annotation("", coordinate: coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .viewSize(34)
                        .foregroundStyle(.white, theme.colors.statusError)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                }
            }
            .saturation(isEnded ? 0 : 1)
            .ignoresSafeArea()

            headerBar

            VStack {
                Spacer()
                if case .liveLocation(let liveLocation, let isMine) = kind {
                    liveStatusBar(liveLocation, isMine: isMine)
                }
                openInMapsButton
            }
        }
        .background(theme.colors.mainBG)
    }

    private var headerBar: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.black.opacity(0.4)))
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func liveStatusBar(_ liveLocation: LiveLocation, isMine: Bool) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let isActive = liveLocation.isActive

            HStack(spacing: 12) {
                LiveLocationStatusText(
                    isActive: isActive,
                    subtitle: liveLocation.expiresAt.countdownText()
                )

                Spacer()

                if isActive && isMine {
                    Button(action: onStopSharing) {
                        Text(localization.stopSharingLocationText)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(14, 8)
                            .background(Capsule().fill(theme.colors.statusError))
                    }
                }
            }
            .padding(16, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(14)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private var openInMapsButton: some View {
        Button {
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.openInMaps()
        } label: {
            Text(localization.openInMapsText)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.colors.mainTint)
                .cornerRadius(12)
        }
        .padding()
    }
}
