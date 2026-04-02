//
//  StockSymbolListViewModel.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation
import Combine

protocol StockSymbolListViewModelDelegate: AnyObject {
    func didReload()
    func didUpdateConnection(_ isConnected: Bool)
}

final class StockSymbolListViewModel {
    weak var delegate: StockSymbolListViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    let stockManager: StockManager
    private(set) var stocks: [StockSymbolDataModel] = []

    init(stockManager: StockManager) {
        self.stockManager = stockManager
        self.stockManager.delegate = self
    }

    func loadStocks() {
        stocks = stockManager.getStocks()
        bindStocks()
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
    
    private func bindStocks() {
        stockManager.$stocks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stocks in
                guard let self = self else { return }
                self.stocks = stocks
                delegate?.didReload()
            }
            .store(in: &cancellables)
    }
}

// MARK: - StockManager Delegate
extension StockSymbolListViewModel: StockManagerDelegate {
    func didUpdateConnection(_ isConnected: Bool) {
        delegate?.didUpdateConnection(isConnected)
    }
}
