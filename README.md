# OptionsPro iOS App

OptionsPro is an advanced options strategy calculator and IV surface visualizer for iOS.

## Features
- Real-time IV data from Polygon.io via WebSocket
- Black-Scholes pricing and Newton-Raphson IV solver
- Multiple option spreads (vertical, butterfly, iron condor, diagonal, double diagonal)
- IV skew chart with multiple expirations toggle
- 3D animated IV surface visualization with SceneKit
- Dark mode and haptic feedback
- CSV export support
- Early exercise/assignment payoff logic with binomial tree

## Setup

1. Clone the repo
2. Open `OptionsPro.xcodeproj` in Xcode
3. Add your Polygon.io API key in `PolygonWebSocketClient.swift`
4. Run on device or simulator (requires iOS 16+)

## License

MIT License
