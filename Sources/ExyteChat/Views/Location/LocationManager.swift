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

    private let manager = CLLocationManager()
    private var wantsContinuousUpdates = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// Keeps publishing `currentLocation` updates as the device moves, until `stopContinuousUpdates()` is called.
    func startContinuousUpdates() {
        wantsContinuousUpdates = true
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = manager.authorizationStatus == .authorizedAlways && Self.supportsBackgroundLocationUpdates
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func stopContinuousUpdates() {
        wantsContinuousUpdates = false
        if Self.supportsBackgroundLocationUpdates {
            manager.allowsBackgroundLocationUpdates = false
        }
        manager.stopUpdatingLocation()
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
            guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
            if self.wantsContinuousUpdates {
                manager.allowsBackgroundLocationUpdates = status == .authorizedAlways && Self.supportsBackgroundLocationUpdates
                manager.startUpdatingLocation()
            } else {
                manager.requestLocation()
            }
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
