//
//  main.swift
//  Benchmark-Swift
//
//  Created by 김동현 on 12/12/25.
//

import Foundation
import DifferenceKit

let runner = BenchmarkRunner(
    
    // Swift 기본 CollectionDifference
    Benchmark(name: "SwiftDiff") { data in
        return {
            _ = data.target.difference(from: data.source).inferringMoves()
        }
    },
    
    // DifferenceKit
    Benchmark(name: "DifferenceKit") { data in
        return {
            _ = StagedChangeset(source: data.source, target: data.target)
        }
    }
)

runner.run(with: BenchmarkData(
    count: 5000,
    deleteRange: 2000..<3000,
    insertRange: 3000..<4000,
    shuffleRange: 0..<200
))

runner.run(with: BenchmarkData(
    count: 100000,
    deleteRange: 20000..<30000,
    insertRange: 30000..<40000,
    shuffleRange: 0..<2000
))



//let sortBenchmark = Benchmark(
//    name: "Array Sort",
//    prepare: { data in
//        return {
//            _ = data.source.sorted()
//        }
//    }
//)
//
//let containsBenchmark = Benchmark(
//    name: "Contains Check",
//    prepare: { data in
//        let value = data.source.randomElement()!
//        return {
//            _ = data.target.contains(value)
//        }
//    }
//)
//
//let runner = BenchmarkRunner(
//    sortBenchmark,
//    containsBenchmark
//)
//
//runner.run(with: BenchmarkData(
//    count: 5000,
//    deleteRange: 2000..<3000,
//    insertRange: 3000..<4000,
//    shuffleRange: 0..<200
//))
//
//runner.run(with: BenchmarkData(
//    count: 100000,
//    deleteRange: 20000..<30000,
//    insertRange: 30000..<40000,
//    shuffleRange: 0..<2000
//))

//let data = BenchmarkData(
//    count: 5000,
//    deleteRange: 2000..<3000,
//    insertRange: 3000..<4000,
//    shuffleRange: 0..<200
//)
//
//runner.run(with: data)
