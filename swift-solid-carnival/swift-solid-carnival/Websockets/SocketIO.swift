//
//  SocketIO.swift
//  swift-solid-carnival
//
//  Created by m1_air on 11/3/24.
//

import Foundation
import SocketIO
import Observation

enum SocketConfig {
    static let development_url = "http://127.0.0.1:4000"
}

@Observable class SocketService {
    
    var message: String = ""
    var connected: Bool = false
    static let shared = SocketService()
    private let manager: SocketManager
    let socket: SocketIOClient
    
    var confirmedServerConnection: Bool = false
    var userListUpdateRequired: Bool = false
    var updateChatMessages: Double = 0.0
     
    private init() {
        let url = URL(string: SocketConfig.development_url)!
        manager = SocketManager(socketURL: url, config: [.log(true), .forceWebsockets(true)])
        socket = manager.defaultSocket
        setupSocketConnection()
    }
    
    private func setupSocketConnection() {
        
        socket.on(clientEvent: .connect) { data, ack in
            self.message = "Mobile Socket connected"
            self.connected = true
            self.confirmedServerConnection = true
        }
        
    }
    
    deinit {
            socket.disconnect()
        }
}
