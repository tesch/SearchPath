//
// SearchManager Search Component.swift
//
// Created by Marcel Tesch on 2021-11-14.
// Think different.
//

import Foundation

extension SearchManager {

    func searchCache(directoryTree: DirectoryTree, component: SearchPath.Pattern.Component, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        let key = ComponentKey(directoryTree: directoryTree, component: component, isRelative: isRelative, isNegated: isNegated, options: options)

        return try await componentCache.cacheValue(forKey: key) {
            try await search(directoryTree: directoryTree, component: component, isRelative: isRelative, isNegated: isNegated, options: options)
        }
    }

}

private extension SearchManager {

    func search(directoryTree: DirectoryTree, component: SearchPath.Pattern.Component, isRelative: Bool, isNegated: Bool, options: Options) async throws -> DirectoryTree {
        try Task.checkCancellation()

        switch (component, isNegated) {
        case (.content(let string), _):
            if string == "~", isRelative == false { return .home }

            switch string {
            case ".":
                return directoryTree

            case "..":
                return directoryTree.parents

            case "...":
                return try await recursiveSearch(directoryTree: directoryTree)

            default:
                guard let predicate = Predicate(string: string, options: options) else { throw SearchPath.InvalidComponent(content: string) }

                return await search(directoryTree: directoryTree, predicate: predicate, isNegated: isNegated)
            }

        case (.negation(let pattern), _):
            return try await searchCache(directoryTree: directoryTree, pattern: pattern, isRelative: isRelative, isNegated: isNegated == false, options: options)

        case (.union(let patterns), false), (.intersection(let patterns), true):
            return try await searchUnion(directoryTree: directoryTree, patterns: patterns, isRelative: isRelative, isNegated: isNegated, options: options)

        case (.intersection(let patterns), false), (.union(let patterns), true):
            return try await searchIntersection(directoryTree: directoryTree, patterns: patterns, isRelative: isRelative, isNegated: isNegated, options: options)
        }
    }

}
