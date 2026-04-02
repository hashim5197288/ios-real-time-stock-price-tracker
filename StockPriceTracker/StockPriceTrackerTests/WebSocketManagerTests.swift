//
//  WebSocketManagerTests.swift
//  StockPriceTrackerTests
//
//  Created by M.Hashim on 02/04/2026.
//

import Testing
@testable import StockPriceTracker

// MARK: - Mock Delegate
final class MockWebSocketDelegate: WebSocketManagerDelegate {

    var receivedMessages: [String] = []
    var connectionStates: [Bool] = []

    func didReceiveEcho(message: String) {
        receivedMessages.append(message)
    }

    func didUpdateConnection(isConnected: Bool) {
        connectionStates.append(isConnected)
    }
}

// MARK: - Tests
struct WebSocketManagerTests {

    // MARK: - Test disconnect updates connection state
    @Test
    func testDisconnectUpdatesConnectionState() {
        let manager = WebSocketManager()
        let mock = MockWebSocketDelegate()
        manager.delegate = mock

        manager.disconnect()

        #expect(mock.connectionStates.last == false)
    }

    // MARK: - Test multiple disconnect calls
    @Test
    func testMultipleDisconnectCalls() {
        let manager = WebSocketManager()
        let mock = MockWebSocketDelegate()
        manager.delegate = mock

        manager.disconnect()
        manager.disconnect()

        #expect(mock.connectionStates.count == 2)
        #expect(mock.connectionStates.allSatisfy { $0 == false })
    }

    // MARK: - Test send when not connected
    @Test
    func testSendBeforeConnectionDoesNotCrashOrSend() {
        let manager = WebSocketManager()
        let mock = MockWebSocketDelegate()
        manager.delegate = mock

        manager.send(message: "Hello")

        #expect(mock.receivedMessages.isEmpty)
    }

    // MARK: - Test delegate assignment works
    @Test
    func testDelegateAssignment() {
        let manager = WebSocketManager()
        let mock = MockWebSocketDelegate()

        manager.delegate = mock

        manager.disconnect()

        #expect(mock.connectionStates.contains(false))
    }
}
