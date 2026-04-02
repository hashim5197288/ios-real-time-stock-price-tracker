//
//  StockSymbolDetailViewController.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 01/04/2026.
//

import UIKit

final class StockSymbolDetailViewController: UIViewController {

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var viewModel: StockDetailViewModel!

    func configure(symbol: String, stockManager: StockManager) {
        viewModel = StockDetailViewModel(stockManager: stockManager, symbol: symbol)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadStockDetails()
    }
}

// MARK: - ViewModel Delegate -

extension StockSymbolDetailViewController: StockSymbolDetailViewModelDelegate {
    
    func didUpdateStock(_ stock: StockSybmolDataModel) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            title = stock.symbol
            companyNameLabel.text = stock.name
            priceLabel.text = "$\(stock.price.formatToTwoDecimal())"
            changeLabel.text = "\(stock.change.formatToTwoDecimal())"
            changeLabel.textColor = stock.change >= 0 ? .systemGreen : .systemRed
            descriptionLabel.text = stock.description
        }
    }
}
