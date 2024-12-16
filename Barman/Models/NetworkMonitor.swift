//
//  NetworkMonitor.swift
//  Barman
//
//  Created by Carlos Padilla on 27/02/23.
//

import Foundation
import Network
import UIKit

class NetworkMonitor: NSObject {
    
    var internetStatus = false
    var internetType = ""
    
    static let instance = NetworkMonitor()
    
    override private init() {
        super.init()
        startDetection()
    }
    
    func startDetection() {
        // A Network Path Monitor is started for detection.
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.internetStatus = true
                if path.usesInterfaceType(.wifi) {
                    self.internetType = "WiFi"
                } else {
                    self.internetType = "No WiFi"
                }
            } else {
                self.internetStatus = false
                self.internetType = ""
            }
        }
    }
}
