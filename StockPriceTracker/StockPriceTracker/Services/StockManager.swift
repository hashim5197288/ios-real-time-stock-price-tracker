//
//  StockManager.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation
import Combine

/// Delegate that receives high-level connection state from StockManager.
/// The manager forwards connection updates from its underlying transport.
protocol StockManagerDelegate: AnyObject {
    func didUpdateConnection(_ isConnected: Bool)
}

/// Central domain manager for stock data.
///
/// Responsibilities:
/// - Generates an initial in-memory list of stocks on initialization.
/// - Manages a WebSocket-backed price feed and forwards connection state via a delegate.
/// - Publishes an array of `StockSymbolDataModel` via `@Published` for UI consumption.
/// - Applies real-time price updates by parsing echo messages and computing price change.
///
/// Lifecycle:
/// - start(): Connects to the WebSocket and begins simulated price generation.
/// - stop(): Disconnects the WebSocket and invalidates the price generation timer.
///
/// Update flow:
/// 1. A periodic timer picks a random symbol and sends a new price via the WebSocket.
/// 2. The echo server returns the message, which is received in `didReceiveEcho`.
/// 3. The manager parses the symbol and price, updates the matching stock's `price` and `change`,
///    and republishes `stocks` so observers are notified.
final class StockManager {

    /// Receiver of connection state updates forwarded from the underlying WebSocket.
    weak var delegate: StockManagerDelegate?
    
    /// Transport responsible for sending/receiving price messages (echo server in this demo).
    private let socket = WebSocketManager()
    /// Current list of stocks. Mutations trigger Combine updates to any subscribers.
    @Published private(set) var stocks: [StockSymbolDataModel] = []
    
    /// Periodic generator that simulates outbound price messages for the echo server.
    private var timer: Timer?
    
    /// Initializes the manager, wires the socket delegate, and seeds initial stocks.
    init() {
        socket.delegate = self
        generateInitialStocks()
    }

    /// Starts the live price feed by connecting the WebSocket.
    func start() {
        socket.connect()
    }
    
    /// Stops the live price feed by disconnecting the WebSocket and invalidating the timer.
    func stop() {
        socket.disconnect()
        timer?.invalidate()
    }
    
    /// Returns the current snapshot of stocks.
    func getStocks() -> [StockSymbolDataModel] {
        return stocks
    }
    
    /// Seeds a fixed set of demo symbols with random initial prices.
    private func generateInitialStocks() {
        let symbols = ["AAPL","GOOG","TSLA","AMZN","MSFT","NVDA","META","NFLX","BABA","INTC",
                       "AMD","ORCL","IBM","SAP","UBER","LYFT","SHOP","SQ","PYPL","SONY",
                       "ADBE","CRM","CSCO","QCOM","TXN"]
        
        stocks = symbols.map {
            StockSymbolDataModel(symbol: $0,
                                 name: $0 + " Inc.",
                                 description: "A leading global company driving innovation and delivering long-term value to investors.",
                                 price: Double.random(in: 100...1000),
                                 change: 0)
        }
    }
    
    /// Starts a repeating timer that selects a random symbol and emits a new price via WebSocket.
    private func startGeneratingPrices() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.updateRandomStock()
        }
    }
    
    /// Picks a random stock and sends a new random price. The echo response drives the actual update.
    private func updateRandomStock() {
        guard let index = stocks.indices.randomElement() else { return }
        let newPrice = Double.random(in: 100...1000)
        
        let message = "\(stocks[index].symbol):\(newPrice)"
        socket.send(message: message)
    }
    
    /// Test helper to deterministically update a specific symbol's price without using the socket.
    /// - Parameters:
    ///   - symbol: The target symbol to update.
    ///   - price: The new price to set.
    #if DEBUG
    func updateStockForTest(_ symbol: String, price: Double) {
        if let index = stocks.firstIndex(where: { $0.symbol == symbol }) {
            stocks[index].price = price
            stocks[index].change = 0
            stocks = stocks
        }
    }
    #endif
}

// MARK: - WebSocketManagerDelegate
extension StockManager: WebSocketManagerDelegate {
    
    /// Parses an echo message of the form "SYMBOL:PRICE" and applies the price and change to the matching stock.
    func didReceiveEcho(message: String) {
        print("Echo:", message)
        let parts = message.split(separator: ":")
        guard parts.count == 2,
              let price = Double(parts[1]) else { return }
        
        let symbol = String(parts[0])
        
        if let index = stocks.firstIndex(where: { $0.symbol == symbol }) {
            
            let oldPrice = stocks[index].price
            
            stocks[index].price = price
            stocks[index].change = price - oldPrice
            
            self.stocks = stocks
        }
    }
    
    /// Forwards connection state to the delegate and starts/stops the local price generator accordingly.
    func didUpdateConnection(isConnected: Bool) {
        delegate?.didUpdateConnection(isConnected)
        if isConnected {
            startGeneratingPrices()
        } else {
            timer?.invalidate()
        }
    }
}
