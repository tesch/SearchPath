//
// SearchManager Search Pattern.swift
//
// Created by Marcel Tesch on 2021-11-14.
// Think different.
//

import Foundation

extension SearchManager {

    func searchCache(directoryTree: DirectoryTree, pattern: SearchPath.Pattern, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        let key = PatternKey(directoryTree: directoryTree, pattern: pattern, isRelative: isRelative, isNegated: isNegated, options: options)

        return try await patternCache.cacheValue(forKey: key) {
            try await search(directoryTree: directoryTree, pattern: pattern, isRelative: isRelative, isNegated: isNegated, options: options)
        }
    }

}

private extension SearchManager {

    func search(directoryTree: DirectoryTree, pattern: SearchPath.Pattern, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        var (result, isRelative) = (directoryTree, isRelative)

        if pattern.isRoot, isRelative == false {
            (result, isRelative) = (.root, true)
        }

        for component in pattern.components {
            (result, isRelative) = (try await searchCache(directoryTree: result, component: component, isRelative: isRelative, isNegated: isNegated, options: options), true)
        }

        return pattern.isDirectory ? result.directories : result
    }

}
