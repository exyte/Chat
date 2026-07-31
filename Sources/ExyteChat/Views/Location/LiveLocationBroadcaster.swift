//
//  LiveLocationBroadcaster.swift
//  Chat
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LiveLocationBroadcaster: ObservableObject {

    struct ActiveShare {
        let messageId: String
        let startedAt: Date
        let expiresAt: Date
    }

    @Published private(set) var activeShare: ActiveShare?

    var onEvent: ((LiveLocationBroadcastEvent) -> Void)?

    private let locationManager = LocationManager()
    private var cancellable: AnyCancellable?
    private var expiryTimer: Timer?
    private var lastCoordinate: CLLocationCoordinate2D?

    /// Only one share can broadcast at a time - starting a new one ends whichever was already active
    /// (its `.ended` event fires before this new share's first `.updated`).
    func start(messageId: String, startedAt: Date, expiresAt: Date) {
        finish()

        guard expiresAt > Date() else { return }
        activeShare = ActiveShare(messageId: messageId, startedAt: startedAt, expiresAt: expiresAt)
        lastCoordinate = nil

        locationManager.startContinuousUpdates()
        cancellable = locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                guard let self, let share = self.activeShare else { return }
                self.lastCoordinate = coordinate
                let liveLocation = LiveLocation(
                    coordinate: coordinate,
                    lastUpdateAt: Date(),
                    startedAt: share.startedAt,
                    expiresAt: share.expiresAt
                )
                self.onEvent?(.updated(messageId: share.messageId, liveLocation: liveLocation))
            }

        expiryTimer = Timer.scheduledTimer(withTimeInterval: expiresAt.timeIntervalSinceNow, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.finish()
            }
        }
    }

    func finish() {
        guard let share = activeShare else { return }
        locationManager.stopContinuousUpdates()
        cancellable = nil
        expiryTimer?.invalidate()
        expiryTimer = nil
        activeShare = nil
        lastCoordinate = nil
        onEvent?(.ended(messageId: share.messageId))
    }
}
