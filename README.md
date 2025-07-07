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
2. Open the project in Xcode (minimum iOS 16)
3. Add your Polygon.io API key in `Secrets.swift`
4. Build & run on device or simulator

## Notes

- The WebSocket client connects to Polygon.io for live IV data
- Some payoff logic and binomial tree pricing are placeholders and can be extended
- Advanced features like Metal rendering and onboarding screens are planned

## License

MIT License
