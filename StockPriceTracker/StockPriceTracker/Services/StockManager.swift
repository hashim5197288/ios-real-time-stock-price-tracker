//
//  StockManager.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation

protocol StockManagerDelegate: AnyObject {
    func didUpdateStocks(_ stocks: [StockSybmolDataModel])
    func didUpdateConnection(_ isConnected: Bool)
}

final class StockManager {

    weak var delegate: StockManagerDelegate?
    
    private let socket = WebSocketManager()
    private(set) var stocks: [StockSybmolDataModel] = []
    
    private var timer: Timer?
    
    init() {
        socket.delegate = self
        generateInitialStocks()
    }

    func start() {
        socket.connect()
    }
    
    func stop() {
        socket.disconnect()
        timer?.invalidate()
    }
    
    func getStocks() -> [StockSybmolDataModel] {
        return stocks
    }
    
    private func generateInitialStocks() {
        let symbols = ["AAPL","GOOG","TSLA","AMZN","MSFT","NVDA","META","NFLX","BABA","INTC",
                       "AMD","ORCL","IBM","SAP","UBER","LYFT","SHOP","SQ","PYPL","SONY",
                       "ADBE","CRM","CSCO","QCOM","TXN"]
        
        stocks = symbols.map {
            StockSybmolDataModel(symbol: $0,
                                 name: $0 + " Inc.",
                                 description: "A leading global company driving innovation and delivering long-term value to investors.",
                                 price: Double.random(in: 100...1000),
                                 change: 0)
        }
    }
    
    private func startGeneratingPrices() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.updateRandomStock()
        }
    }
    
    private func updateRandomStock() {
        guard let index = stocks.indices.randomElement() else { return }
        let newPrice = Double.random(in: 100...1000)
        
        let message = "\(stocks[index].symbol):\(newPrice)"
        socket.send(message: message)
    }
}

// MARK: - WebSocketManagerDelegate
extension StockManager: WebSocketManagerDelegate {
    
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
            
            delegate?.didUpdateStocks(stocks)
        }
    }
    
    func didUpdateConnection(isConnected: Bool) {
        delegate?.didUpdateConnection(isConnected)
        if isConnected {
            startGeneratingPrices()
        } else {
            timer?.invalidate()
        }
    }
}
