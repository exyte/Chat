//
//  MKCoordinateRegion+CloseUp.swift
//  Chat
//

import MapKit

extension MKCoordinateRegion {
    /// A region tightly centered on `coordinate`, used to zoom the map in on a single location.
    static func closeUp(around coordinate: CLLocationCoordinate2D, delta: CLLocationDegrees = 0.01) -> MKCoordinateRegion {
        MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
    }
}
