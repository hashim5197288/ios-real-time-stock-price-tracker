//
//  StockManagerTests.swift
//  StockPriceTrackerTests
//
//  Created by M.Hashim on 02/04/2026.
//

import Testing
@testable import StockPriceTracker

// MARK: - Mock Delegate
final class MockStockManagerDelegate: StockManagerDelegate {

    var connectionStates: [Bool] = []

    func didUpdateConnection(_ isConnected: Bool) {
        connectionStates.append(isConnected)
    }
}

// MARK: - Tests
struct StockManagerTests {

    // MARK: - Test initial stocks are generated
    @Test
    func testInitialStocksAreGenerated() {
        let manager = StockManager()

        let stocks = manager.getStocks()

        #expect(stocks.count == 25)
        #expect(stocks.first?.symbol != nil)
    }

    // MARK: - Test getStocks returns same data
    @Test
    func testGetStocksReturnsData() {
        let manager = StockManager()

        let stocks = manager.getStocks()

        #expect(stocks.isEmpty == false)
    }

    // MARK: - Test didReceiveEcho updates stock price
    @Test
    func testDidReceiveEchoUpdatesStockPrice() {
        let manager = StockManager()

        let initialStock = manager.getStocks().first!
        let symbol = initialStock.symbol

        let newPrice = initialStock.price + 50
        let message = "\(symbol):\(newPrice)"

        manager.didReceiveEcho(message: message)

        let updatedStock = manager.getStocks().first(where: { $0.symbol == symbol })!

        #expect(updatedStock.price == newPrice)
    }

    // MARK: - Test invalid message is ignored
    @Test
    func testInvalidMessageIgnored() {
        let manager = StockManager()

        let before = manager.getStocks()

        manager.didReceiveEcho(message: "INVALID_MESSAGE")

        let after = manager.getStocks()

        #expect(before.map(\.price) == after.map(\.price))
    }

    // MARK: - Test stop invalidates timer safely
    @Test
    func testStopDoesNotCrash() {
        let manager = StockManager()

        manager.stop()

        #expect(true) // if no crash, pass
    }

    // MARK: - Test connection delegate forwarding
    @Test
    func testConnectionDelegateForwarding() {
        let manager = StockManager()
        let mock = MockStockManagerDelegate()
        manager.delegate = mock

        manager.didUpdateConnection(isConnected: true)
        manager.didUpdateConnection(isConnected: false)

        #expect(mock.connectionStates == [true, false])
    }
}
