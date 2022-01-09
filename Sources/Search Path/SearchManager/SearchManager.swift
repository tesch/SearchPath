//
// SearchManager.swift
//
// Created by Marcel Tesch on 2021-10-26.
// Think different.
//

import Foundation

public final class SearchManager {

    public static let shared = SearchManager()

    let patternCache = Cache<PatternKey, DirectoryTree>()

    let componentCache = Cache<ComponentKey, DirectoryTree>()

    let directoryCache = Cache<DirectoryKey, DirectoryTree.Directory>()

    let urlCache = Cache<URL, URL.Contents>()

    public init() {  }

}

extension SearchManager {

    struct PatternKey: Hashable {

        let directoryTree: DirectoryTree

        let pattern: SearchPath.Pattern

        let isRelative: Bool

        let isNegated: Bool

        let options: Options

    }

    struct ComponentKey: Hashable {

        let directoryTree: DirectoryTree

        let component: SearchPath.Pattern.Component

        let isRelative: Bool

        let isNegated: Bool

        let options: Options

    }

    struct DirectoryKey: Hashable {

        let url: URL

        let predicate: Predicate

        let isNegated: Bool

    }

}

public extension SearchManager {

    func search(directoryTree: DirectoryTree, searchPath: SearchPath, isRelative: Bool = false, options: Options = []) async throws -> DirectoryTree {
        try await searchCache(directoryTree: directoryTree, pattern: searchPath.pattern, isRelative: isRelative, isNegated: false, options: options)
    }

    func search(directoryTrees: Array<DirectoryTree>, searchPath: SearchPath, isRelative: Bool = false, options: Options = []) async throws -> DirectoryTree {
        try await withThrowingTaskGroup(of: DirectoryTree.self, returning: DirectoryTree.self) { group in
            for directoryTree in directoryTrees {
                group.addTask {
                    try await self.search(directoryTree: directoryTree, searchPath: searchPath, isRelative: isRelative, options: options)
                }
            }

            return try await group.reduce(.empty) { result, directoryTree in
                result.union(directoryTree)
            }
        }
    }

    func invalidateCache() async {
        await patternCache.invalidate()
        await componentCache.invalidate()
        await directoryCache.invalidate()
        await urlCache.invalidate()
    }

}
