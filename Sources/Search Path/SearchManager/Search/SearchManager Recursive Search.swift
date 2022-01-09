//
// SearchManager Recursive Search.swift
//
// Created by Marcel Tesch on 2021-12-16.
// Think different.
//

import Foundation

extension SearchManager {

    func recursiveSearch(directoryTree: DirectoryTree) async throws -> DirectoryTree {
        let directory = try await recursiveSearch(url: .rootDirectory, directory: directoryTree.directory)

        return DirectoryTree(directory: directory)
    }

}

private extension SearchManager {

    func recursiveSearch(url: URL, directory: DirectoryTree.Directory) async throws -> DirectoryTree.Directory {
        try await withThrowingTaskGroup(of: (DirectoryTree.Identifier, DirectoryTree.Directory).self, returning: DirectoryTree.Directory.self) { group in
            if directory.isLeaf {
                return try await recursiveSearch(url: url).union(directory)
            }

            var result = DirectoryTree.Directory.empty

            for (identifier, attribute) in directory.contents {
                switch attribute {
                case .fileOrDirectory:
                    result.contents[identifier] = .fileOrDirectory

                    guard let identifier = identifier.directory else { break }

                    group.addTask {
                        (identifier, try await self.recursiveSearch(url: identifier.url))
                    }

                case .directory(let directory):
                    group.addTask {
                        (identifier, try await self.recursiveSearch(url: identifier.url, directory: directory))
                    }
                }
            }

            for try await (identifier, directory) in group {
                result.contents.insert(.directory(directory), for: identifier)
            }

            return result
        }
    }

    func recursiveSearch(url: URL) async throws -> DirectoryTree.Directory {
        try Task.checkCancellation()

        return try await withThrowingTaskGroup(of: (DirectoryTree.Identifier, DirectoryTree.Directory).self, returning: DirectoryTree.Directory.self) { group in
            let identifiers = await searchCache(url: url).map(DirectoryTree.Identifier.init(url:))

            var result = DirectoryTree.Directory.leaf

            for identifier in identifiers {
                result.contents[identifier] = .fileOrDirectory

                guard let identifier = identifier.directory, url.contains(identifier.url) == false else { continue }

                group.addTask {
                    (identifier, try await self.recursiveSearch(url: identifier.url))
                }
            }

            for try await (identifier, directory) in group {
                result.contents[identifier] = .directory(directory)
            }

            return result
        }
    }

}
