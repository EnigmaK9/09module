//
//  NetworkReachability.swift
//  Barman
//
//  Created by Carlos Padilla on 27/02/23.
//

import Network

class NetworkReachability {
    
    static let shared = NetworkReachability()
    private var monitor: NWPathMonitor?
    private var isMonitoring = false
    
    var didStartMonitoringHandler: (() -> Void)?
    var didStopMonitoringHandler: (() -> Void)?
    var netStatusChangeHandler: (() -> Void)?
    
    // This property is checked to see if the network is connected or not.
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    // The current interface type (WiFi, cellular, etc.) is returned.
    var interfaceType: NWInterface.InterfaceType? {
        guard let _ = monitor else { return nil }
        return self.availableInterfacesTypes?.first
    }
    
    private var availableInterfacesTypes: [NWInterface.InterfaceType]? {
        guard let monitor = monitor else { return nil }
        return monitor.currentPath.availableInterfaces.map { $0.type }
    }

    private init() { }
    
    func startMonitoring() {
        // Monitoring is started if not already monitoring.
        if isMonitoring { return }
        
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { _ in
            self.netStatusChangeHandler?()
        }
        isMonitoring = true
        didStartMonitoringHandler?()
    }
    
    func stopMonitoring() {
        // Monitoring is canceled if it was previously started.
        if isMonitoring, let monitor = monitor {
            monitor.cancel()
            self.monitor = nil
            isMonitoring = false
            didStopMonitoringHandler?()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
