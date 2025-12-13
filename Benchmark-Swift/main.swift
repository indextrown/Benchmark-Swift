//
//  main.swift
//  Benchmark-Swift
//
//  Created by 김동현 on 12/12/25.
//

import Foundation
import DifferenceKit
import Differentiator

let runner = BenchmarkRunner(
    
    // Swift 기본 CollectionDifference
    Benchmark(name: "SwiftDiff") { data in
        return {
            _ = data.target.difference(from: data.source).inferringMoves()
        }
    },
    
    // RxDataSources
    Benchmark(name: "RxDataSources") { data in
        let model = UUID()
        let initialSections = [AnimatableSectionModel(model: model, items: data.source)]
        let finalSections = [AnimatableSectionModel(model: model, items: data.target)]
        return {
            _ = try! Diff.differencesForSectionedView(initialSections: initialSections, finalSections: finalSections)
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





let wrapperRunner = BenchmarkWrapperRunner(

    BenchmarkWrapper(name: "Find (no compression)") {
        
        // 데이터 정의
        let n = 10_000 /// 전체 노드 수
        let queries = Array(repeating: n - 1, count: 10_000)
        func makeWorstParent(_ n: Int) -> [Int] {
            var parent = Array(0..<n)
            for i in 1..<n {
                parent[i] = i - 1
            }
            return parent
        }
        
        // 데이터 생성
        let parentBase = makeWorstParent(n)
        let parent = parentBase

        // 실행부만 반환
        return {
            func find(_ node: Int) -> Int {
                var current = node
                while parent[current] != current {
                    current = parent[current]
                }
                return current
            }

            for q in queries {
                _ = find(q)
            }
        }
    },

    BenchmarkWrapper(name: "Find (with compression)") {
        
        // 데이터 정의
        let n = 10_000
        let queries = Array(repeating: n - 1, count: 10_000)
        func makeWorstParent(_ n: Int) -> [Int] {
            var parent = Array(0..<n)
            for i in 1..<n {
                parent[i] = i - 1
            }
            return parent
        }
        
        // 데이터 생성
        let parentBase = makeWorstParent(n)
        var parent = parentBase

        // 실행부만 반환
        return {
            func find(_ node: Int) -> Int {
                var current = node
                while parent[current] != current {
                    current = parent[current]
                }

                let root = current
                current = node

                while parent[current] != current {
                    let next = parent[current]
                    parent[current] = root
                    current = next
                }

                return root
            }

            for q in queries {
                _ = find(q)
            }
        }
    }
)

wrapperRunner.run()
