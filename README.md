**Real-Time Stock Price Tracker (iOS)**
A real-time stock tracking iOS application built using MVVM + Combine + WebSocket architecture, simulating live market behavior with dynamic price updates, sorting capabilities, and detailed symbol views.
This project demonstrates scalable iOS architecture design, real-time data flow management, and a unit testing strategy suitable for CI pipelines.
 
**Features**
Live Stock List
•    Displays 25 stock symbols (AAPL, GOOG, TSLA, AMZN, NVDA, etc.)
•    Real-time price updates across the list
•    Live price change indicator (up/down tracking)
WebSocket Integration
•    Uses: wss://ws.postman-echo.com/raw
•    Sends randomly generated stock price updates
•    Receives echoed response and updates UI in real time
•    Maintains persistent socket connection state
Real-Time Price Engine
•    Random price generation every few seconds
•    Timer-based simulation of market feed
•    Updates propagated across all screens via shared data layer
Sorting Support
•    Sort by Price (High to Low)
•    Sort by Price Change (High to Low)
Stock Detail Screen
•    Displays selected stock symbol details
•    Live updating price and change indicator
•    Connection status indicator (Connected / Disconnected)
•    Start / Stop feed control button
 
**Architecture**
This project follows MVVM architecture with Combine-based reactive data flow.
Layers
- View Layer (UIKit)
•    StockSymbolListViewController
•    StockSymbolDetailViewController
Handles UI rendering and user interaction only.
- ViewModel Layer
StockSymbolListViewModel
•    Manages stock list state
•    Handles sorting logic
•    Binds to StockManager using Combine
•    Forwards connection state updates
StockSymbolDetailViewModel
•    Filters specific stock symbol
•    Listens to live updates from StockManager
•    Emits updated stock via delegate
**Data Layer**
StockManager
Acts as single source of truth: - Maintains stock list - Generates initial dataset - Handles WebSocket connection lifecycle - Simulates real-time price updates via Timer - Publishes updates using @Published

**WebSocket Layer**
WebSocketManager
•    Manages connection using URLSessionWebSocketTask
•    Sends and receives messages
•    Handles echo-based response flow
•    Maintains connection state
 
**Data Flow**
WebSocketManager → StockManager (State + Timer + Price Engine) → Combine (@Published stocks) → ViewModels (List + Detail) → Delegates → ViewControllers → UIKit UI Update
 
**Technical Highlights**
•    MVVM architecture with clear separation of concerns
•    Combine for reactive state propagation
•    WebSocket real-time communication
•    Timer-based market simulation engine
•    Delegate + Combine hybrid communication strategy
•    Single source of truth (StockManager)
•    Modular and scalable design approach
 
**Unit Testing Strategy**
This project includes Swift Testing framework (@Test) based tests.
Coverage Areas
ViewModel Logic
•    Stock filtering validation
•    Sorting logic verification
•    Delegate callback validation
Data Flow Testing
•    Combine-based stock updates
•    Real-time binding validation
WebSocket Simulation
•    Connection state handling
•    Message echo processing
Mocking Strategy
•    Delegate mocks for verification
•    Test helper methods for controlled stock mutation
 
**Key Design Decisions**
Single Source of Truth
All stock updates originate from StockManager ensuring consistency.
Combine + Delegate Hybrid
•    Combine for data binding
•    Delegate for UI communication
Testable Architecture
•    private(set) state protection
•    Controlled test hooks added
•    Deterministic unit testing support
Real-Time Simulation
•    WebSocket echo server
•    Timer-based updates
•    Random price generation engine
 
**How to Run**
1.    Clone repository
2.    Open .xcodeproj
3.    Run on iOS Simulator (iOS 16+ recommended)
4.    Tap Start Price Feed to begin real-time updates
5.    Tap on any stock to see further details
