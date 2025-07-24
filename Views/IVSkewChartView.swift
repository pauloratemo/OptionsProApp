import SwiftUI
import Charts

struct IVSkewChartView: View {
    let ivPoints: [OptionIVPoint]
    @Environment(\.colorScheme) var colorScheme
    
    var lineColor: Color {
        colorScheme == .dark ? .cyan : .blue
    }
    
    var body: some View {
        Chart {
            ForEach(ivPoints) { point in
                LineMark(
                    x: .value("Strike", point.strike),
                    y: .value("IV", point.iv)
                )
                .foregroundStyle(lineColor)
                .interpolationMethod(.catmullRom)
                .symbol(Circle())
            }
        }
        .chartXAxisLabel("Strike Price")
        .chartYAxisLabel("Implied Volatility")
        .chartYScale(domain: .automatic(includesZero: false))
        .background(colorScheme == .dark ? Color.black : Color.white)
        .animation(.easeInOut, value: ivPoints)
        .padding()
    }
}
