//
//  LiveLocation.swift
//  Chat
//

import Foundation
import CoreLocation

public struct LiveLocation: Codable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double
    public var lastUpdateAt: Date
    public var startedAt: Date
    public var expiresAt: Date

    public init(latitude: Double, longitude: Double, lastUpdateAt: Date = Date(), startedAt: Date, expiresAt: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.lastUpdateAt = lastUpdateAt
        self.startedAt = startedAt
        self.expiresAt = expiresAt
    }

    public var isActive: Bool {
        Date() < expiresAt
    }

    public var isEnded: Bool {
        !isActive
    }

    /// Fraction of the share's total duration still remaining: `1.0` right after it started, `0.0` once
    /// `expiresAt` is reached.
    public func remainingFraction() -> Double {
        let total = expiresAt.timeIntervalSince(startedAt)
        guard total > 0 else { return 0 }
        let remaining = expiresAt.timeIntervalSince(Date())
        return min(1, max(0, remaining / total))
    }

    /// "updated just now" / "updated N min ago", localized, based on `lastUpdateAt`.
    func updatedAgoText(localization: ChatLocalization) -> String {
        let seconds = lastUpdateAt.secondsElapsed()
        if seconds < 60 {
            return localization.liveLocationUpdatedJustNowText
        }
        return String(format: localization.liveLocationUpdatedMinutesAgoFormat, seconds / 60)
    }
}

public extension LiveLocation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(coordinate: CLLocationCoordinate2D, lastUpdateAt: Date = Date(), startedAt: Date, expiresAt: Date) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude, lastUpdateAt: lastUpdateAt, startedAt: startedAt, expiresAt: expiresAt)
    }
}

/// Preset durations offered when starting a live location share
public enum LiveLocationDuration: Int, CaseIterable, Identifiable, Sendable {
    case fifteenMinutes
    case oneHour
    case eightHours

    public var id: Self { self }

    public var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60
        case .oneHour: return 60 * 60
        case .eightHours: return 8 * 60 * 60
        }
    }

    public var title: String {
        switch self {
        case .fifteenMinutes: return String(localized: "15 minutes")
        case .oneHour: return String(localized: "1 hour")
        case .eightHours: return String(localized: "8 hours")
        }
    }
}
