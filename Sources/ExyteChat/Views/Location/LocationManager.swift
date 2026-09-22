//
//  LocationManager.swift
//  Chat
//

import Foundation
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus

    private enum LocationType {
        case staticLocation
        case liveLocation
    }

    private let manager = CLLocationManager()
    /// Resumed by `locationManagerDidChangeAuthorization` once the user answers the system prompt.
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestStaticLocation() {
        Task {
            guard await requestPermission() else { return }
            startUpdatingLocation(.staticLocation)
        }
    }

    /// Keeps publishing `currentLocation` updates as the device moves, until `stopUpdatingLiveLocation()` is called.
    func startUpdatingLiveLocation() {
        Task {
            guard await requestPermission() else { return }
            manager.allowsBackgroundLocationUpdates = manager.authorizationStatus == .authorizedAlways && Self.supportsBackgroundLocationUpdates
            startUpdatingLocation(.liveLocation)
        }
    }

    func stopUpdatingLiveLocation() {
        if Self.supportsBackgroundLocationUpdates {
            manager.allowsBackgroundLocationUpdates = false
        }
        manager.stopUpdatingLocation()
    }

    /// Resolves once the user has answered the authorization prompt (or immediately if already
    /// determined), and returns whether we're now allowed to use location. Knows nothing about
    /// what the caller intends to do with that location.
    private func requestPermission() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        default:
            return false
        }
    }

    private func startUpdatingLocation(_ type: LocationType) {
        switch type {
        case .liveLocation:
            manager.startUpdatingLocation()
        case .staticLocation:
            manager.requestLocation()
        }
    }

    /// Background live-location updates only work if the host app opted into the "location" UIBackgroundMode;
    /// otherwise setting `allowsBackgroundLocationUpdates` throws an assertion. Without it, updates still work
    /// while the app is foregrounded/backgrounded briefly, just not indefinitely in the background.
    private static let supportsBackgroundLocationUpdates: Bool = {
        (Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String])?.contains("location") ?? false
    }()
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            guard status != .notDetermined else { return }
            self.authorizationContinuation?.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
            self.authorizationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        Task { @MainActor in
            self.currentLocation = coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}
