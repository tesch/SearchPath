//
// SearchManager Search Directory.swift
//
// Created by Marcel Tesch on 2021-12-10.
// Think different.
//

import Foundation

extension SearchManager {

    func search(directoryTree: DirectoryTree, predicate: Predicate, isNegated: Bool) async -> DirectoryTree {
        let directory = await search(url: .rootDirectory, directory: directoryTree.directory, predicate: predicate, isNegated: isNegated)

        return DirectoryTree(directory: directory)
    }

}

private extension SearchManager {

    func search(url: URL, directory: DirectoryTree.Directory, predicate: Predicate, isNegated: Bool) async -> DirectoryTree.Directory {
        await withTaskGroup(of: (DirectoryTree.Identifier, DirectoryTree.Directory).self, returning: DirectoryTree.Directory.self) { group in
            for (identifier, attribute) in directory.contents {
                switch attribute {
                case .fileOrDirectory:
                    guard let identifier = identifier.directory else { break }

                    group.addTask {
                        (identifier, await self.searchCache(url: identifier.url, predicate: predicate, isNegated: isNegated))
                    }

                case .directory(let directory):
                    group.addTask {
                        (identifier, await self.search(url: identifier.url, directory: directory, predicate: predicate, isNegated: isNegated))
                    }
                }
            }

            var result = directory.isLeaf ? await searchCache(url: url, predicate: predicate, isNegated: isNegated) : .empty

            for await (identifier, directory) in group {
                result.contents.insert(.directory(directory), for: identifier)
            }

            return result
        }
    }

}
