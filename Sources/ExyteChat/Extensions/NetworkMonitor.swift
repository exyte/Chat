//
//  NetworkMonitor.swift
//  
//
//  Created by Alisa Mylnikova on 01.09.2023.
//

import Foundation
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            Task {
                await MainActor.run {
                    self.isConnected = path.status == .satisfied
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
