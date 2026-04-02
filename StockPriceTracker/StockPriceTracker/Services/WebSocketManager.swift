//
//  WebSocketManager.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation

protocol WebSocketManagerDelegate: AnyObject {
    func didReceiveEcho(message: String)
    func didUpdateConnection(isConnected: Bool)
}

final class WebSocketManager {

    weak var delegate: WebSocketManagerDelegate?
    private var task: URLSessionWebSocketTask?
    private let urlString = "wss://ws.postman-echo.com/raw"
    private var isConnected = false
    
    func connect() {
        guard let url = URL(string: urlString) else { return }
        
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        
        listen()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            isConnected = true
            delegate?.didUpdateConnection(isConnected: true)
        }
    }
    
    func disconnect() {
        isConnected = false
        task?.cancel(with: .goingAway, reason: nil)
        
        delegate?.didUpdateConnection(isConnected: false)
    }
    
    func send(message: String) {
        
        guard isConnected else {
            print("Socket not ready yet, skipping send")
            return
        }
        
        task?.send(.string(message)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }
    
    private func listen() {
        task?.receive { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(.string(let text)):
                self.delegate?.didReceiveEcho(message: text)
                self.listen()
                
            case .failure(let error):
                print("Socket error:", error)
                
                self.isConnected = false
                self.delegate?.didUpdateConnection(isConnected: false)
                
                //STOP listening
            default:
                break
            }
        }
    }
}
