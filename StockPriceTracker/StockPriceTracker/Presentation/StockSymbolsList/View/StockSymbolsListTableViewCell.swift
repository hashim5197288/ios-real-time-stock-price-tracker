//
//  StockSymbolsListTableViewCell.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import UIKit

class StockSymbolsListTableViewCell: UITableViewCell {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!

    func configureCell(_ stock: StockSybmolDataModel) {
        symbolLabel.text = stock.symbol
        priceLabel.text = "$\(stock.price.formatToTwoDecimal())"
        changeLabel.text = "\(stock.change.formatToTwoDecimal())"
        changeLabel.textColor = stock.change >= 0 ? .systemGreen : .systemRed
    }
}
