//
//  BenchmarkTools.swift
//  Benchmark-Swift
//
//  Created by 김동현 on 12/12/25.
//

import Foundation
import DifferenceKit

extension UUID: Differentiable {}

struct BenchmarkData {
    var source: [UUID]  // 원본 배열
    var target: [UUID]  // 변경된 배열
    var deleteRange: CountableRange<Int>
    var insertRange: CountableRange<Int>
    var shuffleRange: CountableRange<Int>
    
    init(count: Int,
         deleteRange: CountableRange<Int>,
         insertRange: CountableRange<Int>,
         shuffleRange: CountableRange<Int>
    ) {
        self.source = (0..<count).map { _ in UUID() }
        self.target = source
        self.deleteRange = deleteRange
        self.insertRange = insertRange
        self.shuffleRange = shuffleRange
        
        target.removeSubrange(deleteRange)
        target.insert(contentsOf: insertRange.map { _ in UUID()  }, at: insertRange.lowerBound)
        target[shuffleRange].shuffle()
    }
}

struct Benchmark {
    var name: String
    // var prepare: (BenchmarkData) -> (() -> Void)
    var prepare: (BenchmarkData) -> (() -> Void)
    
    func measure(with data: BenchmarkData) -> CFAbsoluteTime {
        let action = prepare(data)  // 실행 함수 action 생성
        let start = CFAbsoluteTimeGetCurrent()
        action()                    // 실제 실행 측정
        let end = CFAbsoluteTimeGetCurrent()
        return end - start
    }
}

struct BenchmarkRunner {
    var benchmarks: [Benchmark]
    
    init(_ benchmarks: Benchmark...) {
        self.benchmarks = benchmarks
    }
    
    func run(with data: BenchmarkData) {
        let benchmarks = self.benchmarks
        let sourceCount = String.localizedStringWithFormat("%d", data.source.count)
        let deleteCount = String.localizedStringWithFormat("%d", data.deleteRange.count)
        let insertCount = String.localizedStringWithFormat("%d", data.insertRange.count)
        let shuffleCount = String.localizedStringWithFormat("%d", data.shuffleRange.count)
        
        //  표 정렬을 예쁘게 하기 위해 가장 이름이 긴 길이를 얻는다
        let maxLength = benchmarks.lazy
            .map { $0.name.count }
            .max() ?? 0
        
        // let empty = String(repeating: " ", count: maxLength)
        let nameTitle = "Benchmark".padding(toLength: maxLength, withPad: " ", startingAt: 0)
        let timeTitle = "Time(sec)".padding(toLength: maxLength, withPad: " ", startingAt: 0)
        let leftAlignSpacer = ":" + String(repeating: "-", count: maxLength - 1)
        let rightAlignSpacer = String(repeating: "-", count: maxLength - 1) + ":"

        print("#### - From \(sourceCount) elements to \(deleteCount) deleted, \(insertCount) inserted and \(shuffleCount) shuffled")
        print()
        print("""
            |\(nameTitle)|\(timeTitle)|
            |\(leftAlignSpacer)|\(rightAlignSpacer)|
            """)
        
        var results = ContiguousArray<CFAbsoluteTime?>(repeating: nil, count: benchmarks.count)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "Measure benchmark queue", attributes: .concurrent)

        for (offset, benchmark) in benchmarks.enumerated() {
            group.enter()

            queue.async(group: group) {
                let first = benchmark.measure(with: data)
                let second = benchmark.measure(with: data)
                let third = benchmark.measure(with: data)
                results[offset] = min(first, second, third)
                group.leave()
            }
        }

        group.wait()

        for (offset, benchmark) in benchmarks.enumerated() {
            guard let result = results[offset] else {
                fatalError("Measuring was not works correctly.")
            }

            let paddingName = benchmark.name.padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let paddingTime = String(format: "`%.4f`", result).padding(toLength: maxLength, withPad: " ", startingAt: 0)

            print("|\(paddingName)|", terminator: "")
            print("\(paddingTime)|")
        }

        print()
    }
}

