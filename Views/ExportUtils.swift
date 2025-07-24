import Foundation
import SwiftUI

func exportIVPointsToCSV(points: [OptionIVPoint]) -> URL? {
    let csvString = points.reduce("Strike,Expiration,IV\n") { partialResult, point in
        partialResult + "\(point.strike),\(point.expiration),\(point.iv)\n"
    }
    
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent("IVPointsExport.csv")
    
    do {
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("CSV export failed: \(error)")
        return nil
    }
}
