//
// SearchManager Search Union.swift
//
// Created by Marcel Tesch on 2021-11-10.
// Think different.
//

import Foundation

extension SearchManager {

    func searchUnion(directoryTree: DirectoryTree, patterns: Array<SearchPath.Pattern>, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        try await withThrowingTaskGroup(of: DirectoryTree.self, returning: DirectoryTree.self) { group in
            for pattern in patterns {
                group.addTask {
                    try await self.searchCache(directoryTree: directoryTree, pattern: pattern, isRelative: isRelative, isNegated: isNegated, options: options)
                }
            }

            var result = DirectoryTree.empty

            for try await directoryTree in group {
                result = result.union(directoryTree)
            }

            return result
        }
    }

}
