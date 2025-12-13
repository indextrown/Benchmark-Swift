//
//  BenchmarkWrapper.swift
//  Benchmark-Swift
//
//  Created by 김동현 on 12/13/25.
//

import Foundation

final class BenchmarkWrapper {
    let name: String
    let iterations: Int
    let prepare: () -> () -> Void
    
    init(name: String,
         iterations: Int = 1,
         prepare: @escaping () -> () -> Void
    ) {
        self.name = name
        self.iterations = iterations
        self.prepare = prepare
    }
    
    /// iterations 만큼 실행하는 단일 측정
    private func measureOnce() -> CFAbsoluteTime {
        let action = prepare()   // 데이터 생성은 여기서
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            action()             // 실행부만 측정
        }
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    /// 3번 측정해서 최소값 반환 (오차 제거)
    func measure() -> CFAbsoluteTime {
        let t1 = measureOnce()
        let t2 = measureOnce()
        let t3 = measureOnce()
        return min(t1, t2, t3)
    }
}

struct BenchmarkWrapperRunner {
    var benchmarks: [BenchmarkWrapper]
    
    init(_ benchmarks: BenchmarkWrapper...) {
        self.benchmarks = benchmarks
    }
    
    func run() {
        let maxLength = benchmarks.map { $0.name.count }.max() ?? 0
        
        let nameTitle = "Benchmark".padding(toLength: maxLength, withPad: " ", startingAt: 0)
        let timeTitle = "Time(sec)".padding(toLength: maxLength, withPad: " ", startingAt: 0)
        let leftAlignSpacer = ":" + String(repeating: "-", count: maxLength - 1)
        let rightAlignSpacer = String(repeating: "-", count: maxLength - 1) + ":"
        
        print()
        print("""
            |\(nameTitle)|\(timeTitle)|
            |\(leftAlignSpacer)|\(rightAlignSpacer)|
            """)
        
        // ✅ 병렬 실행 준비
        var results = ContiguousArray<CFAbsoluteTime?>(repeating: nil, count: benchmarks.count)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "benchmark.runner.queue", attributes: .concurrent)
        
        for (index, benchmark) in benchmarks.enumerated() {
            group.enter()
            queue.async {
                results[index] = benchmark.measure()
                group.leave()
            }
        }
        
        group.wait()
        
        // ✅ 결과 출력
        for (index, benchmark) in benchmarks.enumerated() {
            guard let result = results[index] else { continue }
            
            let name = benchmark.name
                .padding(toLength: maxLength, withPad: " ", startingAt: 0)
            let time = String(format: "%.6f", result)
                .padding(toLength: maxLength, withPad: " ", startingAt: 0)
            
            print("|\(name)|\(time)|")
        }
        
        print()
    }
}


