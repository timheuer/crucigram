import Testing
import Foundation
@testable import Gridlet

@Suite("Grid Density Diagnostics")
struct GridDensityTests {
    @Test("Grid fill density across multiple seeds")
    func gridDensity() {
        for seed: UInt64 in [1, 42, 100, 999, 5555, 12345, 77777, 123456] {
            let gen = CrosswordLayoutGenerator(columns: 5, rows: 5, seed: seed)
            let words = ["APPLE","PLANE","EAGLE","LATER","PEAR","ATE","RAN","CAT",
                         "DOG","TEA","ACE","OAK","SUN","PEN","ICE","NET","LOG",
                         "BAT","HEN","FIG","GUM","RUG","TIN","JAM","VET"]
            gen.generate(words: words)
            let grid = gen.gridLetters()
            let filled = grid.flatMap { $0 }.compactMap { $0 }.count
            let total = 25
            let pct = Double(filled) / Double(total) * 100
            print("Seed \(seed): \(gen.result.count) words, \(filled)/\(total) cells filled (\(Int(pct))%)")
        }

        for seed: UInt64 in [1, 42, 100, 999, 5555, 12345] {
            let gen = CrosswordLayoutGenerator(columns: 6, rows: 6, seed: seed)
            let words = ["GARDEN","CASTLE","BREEZE","FABRIC","INSECT","KITTEN",
                         "ANCHOR","BUTTON","GENTLE","ISLAND","CANDLE","HANDLE",
                         "APPLE","CRANE","EAGLE","FLAME","GRAPE","HOUSE","STONE",
                         "TIGER","BEACH","DREAM","HEART","LEARN","STEAM"]
            gen.generate(words: words)
            let grid = gen.gridLetters()
            let filled = grid.flatMap { $0 }.compactMap { $0 }.count
            let total = 36
            let pct = Double(filled) / Double(total) * 100
            print("6x6 Seed \(seed): \(gen.result.count) words, \(filled)/\(total) cells filled (\(Int(pct))%)")
        }
    }
}
