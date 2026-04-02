//
//  StockSymbolListViewModelTests.swift
//  StockPriceTrackerTests
//
//  Created by M.Hashim on 02/04/2026.
//
import Testing
import Combine
@testable import StockPriceTracker

// MARK: - Mock Delegate
final class MockViewModelDelegate: StockSymbolListViewModelDelegate {

    var reloadCount = 0
    var connectionStates: [Bool] = []

    func didReload() {
        reloadCount += 1
    }

    func didUpdateConnection(_ isConnected: Bool) {
        connectionStates.append(isConnected)
    }
}

// MARK: - Tests
struct StockSymbolListViewModelTests {

    // MARK: - Test loadStocks loads data and triggers reload
    @Test
    func testLoadStocks() {
        let manager = StockManager()
        let vm = StockSymbolListViewModel(stockManager: manager)
        let mock = MockViewModelDelegate()
        vm.delegate = mock

        vm.loadStocks()

        #expect(vm.stocks.count == 25)
        #expect(mock.reloadCount >= 1)
    }

    // MARK: - Test sort by price
    @Test
    func testSortByPrice() {
        let manager = StockManager()
        let vm = StockSymbolListViewModel(stockManager: manager)

        vm.loadStocks()

        vm.sortByPrice()

        let sorted = vm.stocks

        let isSorted = zip(sorted, sorted.dropFirst()).allSatisfy {
            $0.price >= $1.price
        }

        #expect(isSorted == true)
    }

    // MARK: - Test sort by change
    @Test
    func testSortByChange() {
        let manager = StockManager()
        let vm = StockSymbolListViewModel(stockManager: manager)

        vm.loadStocks()

        vm.sortByChange()

        let sorted = vm.stocks

        let isSorted = zip(sorted, sorted.dropFirst()).allSatisfy {
            $0.change >= $1.change
        }

        #expect(isSorted == true)
    }

    // MARK: - Test delegate forwarding connection state
    @Test
    func testConnectionDelegateForwarding() {
        let manager = StockManager()
        let vm = StockSymbolListViewModel(stockManager: manager)

        let mock = MockViewModelDelegate()
        vm.delegate = mock

        vm.didUpdateConnection(true)
        vm.didUpdateConnection(false)

        #expect(mock.connectionStates == [true, false])
    }

    // MARK: - Test start/stop feed (no crash validation)
    @Test
    func testStartStopFeed() {
        let manager = StockManager()
        let vm = StockSymbolListViewModel(stockManager: manager)

        vm.startFeed()
        vm.stopFeed()

        #expect(true) // just ensuring no crash
    }
}
