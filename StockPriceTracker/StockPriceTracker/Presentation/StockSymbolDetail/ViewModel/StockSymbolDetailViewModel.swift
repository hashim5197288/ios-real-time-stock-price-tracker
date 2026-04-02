//
//  StockSymbolDetailViewModel.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation
import Combine

protocol StockSymbolDetailViewModelDelegate: AnyObject {
    func didUpdateStock(_ stock: StockSybmolDataModel)
}

final class StockDetailViewModel {

    weak var delegate: StockSymbolDetailViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    private let stockManager: StockManager
    private let symbol: String

    init(stockManager: StockManager, symbol: String) {
        self.stockManager = stockManager
        self.symbol = symbol
    }
    
    func loadStockDetails() {
        filterStockDetail(allStocks: stockManager.getStocks())
        bindStocks()
    }
    
    private func filterStockDetail(allStocks: [StockSybmolDataModel] ) {
        if let stock = allStocks.first(where: { $0.symbol == symbol }) {
            delegate?.didUpdateStock(stock)
        }
    }

    private func bindStocks() {
        stockManager.$stocks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stocks in
                guard let self = self else { return }
                filterStockDetail(allStocks: stocks)
            }
            .store(in: &cancellables)
    }
}
