//
//  LocationPickerView.swift
//  Chat
//

import SwiftUI
import MapKit
import Combine

struct LocationPickerView: View {

    @Environment(\.chatTheme) var theme
    @Environment(\.dismiss) var dismiss

    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(
        .closeUp(around: CLLocationCoordinate2D(latitude: 0, longitude: 0), delta: 0.05)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var didCenterOnUser = false
    @State private var showLiveDurationDialog = false

    var localization: ChatLocalization
    var onPickStaticLocation: (StaticLocation) -> Void
    var onPickLiveLocation: (LiveLocation) -> Void

    var body: some View {
        NavigationView {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    if let selectedCoordinate {
                        Marker("", coordinate: selectedCoordinate)
                    }
                }
                .onTapGesture { point in
                    if let coordinate = proxy.convert(point, from: .local) {
                        selectedCoordinate = coordinate
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    locationManager.requestLocation()
                } label: {
                    Image(systemName: "location.fill")
                        .padding(12)
                        .background(Circle().fill(theme.colors.inputBG))
                        .foregroundColor(theme.colors.mainTint)
                }
                .padding()
                .padding(.bottom, 60)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    pickerActionButton(localization.sendLocationText, filled: true) {
                        if let selectedCoordinate {
                            onPickStaticLocation(StaticLocation(coordinate: selectedCoordinate))
                            dismiss()
                        }
                    }

                    pickerActionButton(localization.shareLiveLocationText, filled: false) {
                        showLiveDurationDialog = true
                    }
                }
                .padding()
                .background(theme.colors.mainBG)
            }
            .confirmationDialog(localization.shareLiveLocationText, isPresented: $showLiveDurationDialog, titleVisibility: .visible) {
                ForEach(LiveLocationDuration.allCases) { duration in
                    Button(duration.title) {
                        if let selectedCoordinate {
                            let startedAt = Date()
                            onPickLiveLocation(LiveLocation(
                                coordinate: selectedCoordinate,
                                lastUpdateAt: startedAt,
                                startedAt: startedAt,
                                expiresAt: startedAt.addingTimeInterval(duration.timeInterval)
                            ))
                            dismiss()
                        }
                    }
                }
                Button(localization.cancelButtonText, role: .cancel) {}
            }
            .navigationTitle(localization.attachLocationText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.cancelButtonText) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { newValue in
            guard !didCenterOnUser else { return }
            didCenterOnUser = true
            selectedCoordinate = newValue
            cameraPosition = .region(.closeUp(around: newValue))
        }
    }

    private func pickerActionButton(_ title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        let isDisabled = selectedCoordinate == nil
        let tint = isDisabled ? Color.gray : (filled ? theme.colors.sendButtonBackground : theme.colors.mainTint)

        return Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(filled ? .white : tint)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    if filled {
                        tint
                    } else {
                        RoundedRectangle(cornerRadius: 12).stroke(tint, lineWidth: 1)
                    }
                }
                .cornerRadius(12)
        }
        .disabled(isDisabled)
    }
}
