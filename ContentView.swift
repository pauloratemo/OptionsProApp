import SwiftUI

struct ContentView: View {
    @StateObject var liveViewModel = IVLiveViewModel(ticker: "AAPL")
    @State private var selectedExpiration: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                if let error = liveViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if liveViewModel.isOffline {
                    Text("Offline Mode - Showing last known data")
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
                
                if !liveViewModel.ivPointsByExpiration.isEmpty {
                    Picker("Expiration", selection: $selectedExpiration) {
                        ForEach(liveViewModel.ivPointsByExpiration.keys.sorted(), id: \.self) { exp in
                            Text(exp).tag(Optional(exp))
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: selectedExpiration) { _ in
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                    
                    if let selected = selectedExpiration,
                       let points = liveViewModel.ivPointsByExpiration[selected] {
                        
                        IVSkewChartView(ivPoints: points)
                            .frame(height: 300)
                        
                        Button(action: {
                            let notification = UINotificationFeedbackGenerator()
                            notification.notificationOccurred(.success)
                            if let csvURL = exportIVPointsToCSV(points: points) {
                                print("Exported CSV to \(csvURL.path)")
                                // Add share sheet or UI alert as needed
                            }
                        }) {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                                .foregroundColor(colorScheme == .dark ? .white : .blue)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.blue.opacity(0.1)))
                        }
                        .padding(.bottom)
                    }
                } else {
                    ProgressView("Loading live data...")
                        .onAppear {
                            selectedExpiration = liveViewModel.ivPointsByExpiration.keys.sorted().first
                        }
                }
                
                IVSurfaceSceneView(ivPointsByExpiration: $liveViewModel.ivPointsByExpiration,
                                   selectedExpiration: $selectedExpiration)
                    .frame(height: 300)
                    .padding(.bottom)
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationTitle("Options IV Surface (Live)")
            .preferredColorScheme(nil)
            .onDisappear {
                liveViewModel.disconnect()
            }
        }
    }
}
