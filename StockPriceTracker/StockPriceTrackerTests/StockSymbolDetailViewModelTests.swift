//
//  StockSymbolDetailViewModelTests.swift
//  StockPriceTrackerTests
//
//  Created by M.Hashim on 02/04/2026.
//

import Testing
import Combine
@testable import StockPriceTracker

// MARK: - Mock Delegate
final class MockDetailViewModelDelegate: StockSymbolDetailViewModelDelegate {

    var updatedStock: StockSymbolDataModel?
    var callCount = 0

    func didUpdateStock(_ stock: StockSymbolDataModel) {
        updatedStock = stock
        callCount += 1
    }
}

// MARK: - Tests
struct StockSymbolDetailViewModelTests {

    // MARK: - Test initial load returns correct stock
    @Test
    func testLoadStockDetailsReturnsCorrectStock() {
        let manager = StockManager()
        let stocks = manager.getStocks()

        let target = stocks.first!.symbol

        let vm = StockSymbolDetailViewModel(
            stockManager: manager,
            symbol: target
        )

        let mock = MockDetailViewModelDelegate()
        vm.delegate = mock

        vm.loadStockDetails()

        #expect(mock.updatedStock?.symbol == target)
        #expect(mock.callCount >= 1)
    }

    // MARK: - Test wrong symbol returns nil update
    @Test
    func testInvalidSymbolReturnsNoStock() {
        let manager = StockManager()

        let vm = StockSymbolDetailViewModel(
            stockManager: manager,
            symbol: "INVALID_SYMBOL"
        )

        let mock = MockDetailViewModelDelegate()
        vm.delegate = mock

        vm.loadStockDetails()

        #expect(mock.updatedStock == nil)
    }

    // MARK: - Test filterStockDetail logic directly
    @Test
    func testFilterStockDetailLogic() {
        let manager = StockManager()
        let stocks = manager.getStocks()

        let vm = StockSymbolDetailViewModel(
            stockManager: manager,
            symbol: stocks[0].symbol
        )

        let mock = MockDetailViewModelDelegate()
        vm.delegate = mock

        vm.loadStockDetails()

        #expect(mock.updatedStock?.symbol == stocks[0].symbol)
    }

    // MARK: - Test multiple updates via Combine binding
    @Test
    func testStockUpdatesViaBinding() {
        let manager = StockManager()

        let symbol = manager.getStocks().first!.symbol

        let vm = StockSymbolDetailViewModel(
            stockManager: manager,
            symbol: symbol
        )

        let mock = MockDetailViewModelDelegate()
        vm.delegate = mock

        vm.loadStockDetails()

        // simulate update using test helper
        manager.updateStockForTest(symbol, price: 999)

        #expect(mock.updatedStock?.price == 999)
    }
}
