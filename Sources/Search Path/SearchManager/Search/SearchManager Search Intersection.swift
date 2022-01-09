//
// SearchManager Search Intersection.swift
//
// Created by Marcel Tesch on 2021-11-10.
// Think different.
//

import Foundation

extension SearchManager {

    func searchIntersection(directoryTree: DirectoryTree, patterns: Array<SearchPath.Pattern>, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        try await withThrowingTaskGroup(of: DirectoryTree.self, returning: DirectoryTree.self) { group in
            for pattern in patterns {
                group.addTask {
                    try await self.searchCache(directoryTree: directoryTree, pattern: pattern, isRelative: isRelative, isNegated: isNegated, options: options)
                }
            }

            guard var result = try await group.next() else { return .empty }

            while true {
                if result.isEmpty {
                    group.cancelAll()

                    break
                }

                if let directoryTree = try await group.next() {
                    result = result.intersection(directoryTree)
                } else {
                    break
                }
            }

            return result
        }
    }

}
