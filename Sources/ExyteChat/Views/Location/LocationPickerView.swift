//
//  LocationPickerView.swift
//  Chat
//

import SwiftUI
import MapKit

struct LocationPickerView: View {

    @Environment(\.chatTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var didCenterOnUser = false

    var localization: ChatLocalization
    var onPick: (Location) -> Void

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
                Button {
                    if let selectedCoordinate {
                        onPick(Location(latitude: selectedCoordinate.latitude, longitude: selectedCoordinate.longitude))
                        dismiss()
                    }
                } label: {
                    Text(localization.sendLocationText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCoordinate == nil ? Color.gray : theme.colors.sendButtonBackground)
                        .cornerRadius(12)
                }
                .disabled(selectedCoordinate == nil)
                .padding()
                .background(theme.colors.mainBG)
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
        .onChange(of: locationManager.currentLocation?.latitude) { _, _ in
            guard let newValue = locationManager.currentLocation, !didCenterOnUser else { return }
            didCenterOnUser = true
            selectedCoordinate = newValue
            cameraPosition = .region(
                MKCoordinateRegion(center: newValue, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            )
        }
    }
}
