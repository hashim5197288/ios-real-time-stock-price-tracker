//
//  Double+Extensions.swift
//  StockPriceTracker
//
//  Created by M.Hashim on 02/04/2026.
//

import Foundation

extension Double {
    
    func formatToTwoDecimal() -> String {
        return String(format: "%.2f", self)
    }
}
