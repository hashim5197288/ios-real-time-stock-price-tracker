//
//  WebSocketManager.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation

/// Delegate that receives WebSocket events.
/// - didReceiveEcho(message:): Called when a text message is received from the server.
/// - didUpdateConnection(isConnected:): Called whenever the connection state changes.
protocol WebSocketManagerDelegate: AnyObject {
    func didReceiveEcho(message: String)
    func didUpdateConnection(isConnected: Bool)
}

/// A lightweight wrapper around URLSessionWebSocketTask that manages a simple echo-based
/// WebSocket connection. It exposes connection state and inbound text messages via a delegate.
///
/// Behavior overview:
/// - connect(): Creates and resumes a web socket task, starts listening for incoming messages,
///   and notifies the delegate of a connected state after a short readiness delay.
/// - send(message:): Sends a text message if the socket is connected. Messages are ignored until
///   the socket is marked connected.
/// - listen(): Recursively receives messages and forwards them to the delegate. On errors, it
///   transitions to a disconnected state and stops listening.
/// - disconnect(): Cancels the task and notifies the delegate of a disconnected state.
final class WebSocketManager {

    /// Receiver of incoming messages and connection state updates.
    weak var delegate: WebSocketManagerDelegate?
    /// Underlying URLSession web socket task used to send/receive frames.
    private var task: URLSessionWebSocketTask?
    /// Endpoint used for the echo server. Replace with your production endpoint.
    private let urlString = "wss://ws.postman-echo.com/raw"
    /// Tracks whether the manager considers the socket ready to send messages.
    private var isConnected = false
    
    /// Establishes the WebSocket connection and begins listening for incoming messages.
    /// On success, delegates a connected state after a brief delay to allow readiness.
    func connect() {
        guard let url = URL(string: urlString) else { return }
        
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        
        listen()
        
        // Mark as connected after a small delay to simulate readiness of the echo server.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            isConnected = true
            delegate?.didUpdateConnection(isConnected: true)
        }
    }
    
    /// Gracefully closes the WebSocket connection and notifies the delegate of disconnection.
    func disconnect() {
        isConnected = false
        task?.cancel(with: .goingAway, reason: nil)
        
        delegate?.didUpdateConnection(isConnected: false)
    }
    
    /// Attempts to send a text message over the WebSocket.
    /// - Parameter message: The text payload to send. Ignored if not connected.
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
    
    /// Continuously receives incoming frames and forwards string messages to the delegate.
    /// On failure, marks the connection as disconnected and stops the receive loop.
    private func listen() {
        task?.receive { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(.string(let text)):
                self.delegate?.didReceiveEcho(message: text)
                // Continue listening for the next message.
                self.listen()
                
            case .failure(let error):
                print("Socket error:", error)
                
                // Transition to disconnected state and stop listening on error.
                self.isConnected = false
                self.delegate?.didUpdateConnection(isConnected: false)
                
                //STOP listening
            default:
                break
            }
        }
    }
}

