//
//  StockSymbolListViewModel.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation

protocol StockSymbolListViewModelDelegate: AnyObject {
    func didReload()
    func didUpdateConnection(_ isConnected: Bool)
}

final class StockSymbolListViewModel {
    weak var delegate: StockSymbolListViewModelDelegate?
    
    let stockManager: StockManager
    private(set) var stocks: [StockSybmolDataModel] = []

    init(stockManager: StockManager) {
        self.stockManager = stockManager
        self.stockManager.delegate = self
    }

    func loadStocks() {
        stocks = stockManager.getStocks()
        delegate?.didReload()
    }
    
    func startFeed() {
        stockManager.start()
    }
    
    func stopFeed() {
        stockManager.stop()
    }
    
    func sortByPrice() {
        stocks.sort { $0.price > $1.price }
        delegate?.didReload()
    }
    
    func sortByChange() {
        stocks.sort { $0.change > $1.change }
        delegate?.didReload()
    }
}

// MARK: - StockManager Delegate
extension StockSymbolListViewModel: StockManagerDelegate {
    
    func didUpdateStocks(_ stocks: [StockSybmolDataModel]) {
        self.stocks = stocks
        delegate?.didReload()
    }
    
    func didUpdateConnection(_ isConnected: Bool) {
        delegate?.didUpdateConnection(isConnected)
    }
}
