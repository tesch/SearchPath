//
// SearchManager Search URL.swift
//
// Created by Marcel Tesch on 2021-10-29.
// Think different.
//

import Foundation

extension SearchManager {

    func searchCache(url: URL, predicate: Predicate, isNegated: Bool) async -> DirectoryTree.Directory {
        let key = DirectoryKey(url: url, predicate: predicate, isNegated: isNegated)

        return await directoryCache.cacheValue(forKey: key) {
            await search(url: url, predicate: predicate, isNegated: isNegated)
        }
    }

    func searchCache(url: URL) async -> URL.Contents {
        await urlCache.cacheValue(forKey: url) { search(url: url) }
    }

}

private extension SearchManager {

    func search(url: URL, predicate: Predicate, isNegated: Bool) async -> DirectoryTree.Directory {
        let urls = await searchCache(url: url).filter { url in
            let isMatch = predicate.matches(url.lastPathComponent)

            return isNegated ? (isMatch == false) : isMatch
        }

        return DirectoryTree.Directory(isLeaf: false, urls: urls)
    }

    func search(url: URL) -> URL.Contents {
        url.contents(includingHiddenFilesAndDirectories: false) ?? []
    }

}
