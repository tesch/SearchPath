//
// main.swift
//
// Created by Marcel Tesch on 2021-11-15.
// Think different.
//

import ArgumentParser
import Foundation
import SearchPath

@main
struct SearchPathCLI: ParsableCommand {

    static let configuration = CommandConfiguration(commandName: "searchpath", abstract: "Hierarchical file search.", version: "1.0")

    @Argument(help: "Hierarchical search pattern.")
    var pattern: String

    @Argument(help: "Directories to be searched.")
    var paths: Array<String> = []

    @Flag(name: [.customLong("exclusively-relative"), .customLong("relative")])
    var isRelative = false

    @Flag(name: [.customLong("regular-expression"), .customLong("regex")])
    var isRegularExpression = false

    @Flag(name: [.customLong("complete-match"), .customLong("complete")])
    var isCompleteMatch = false

    @Flag(name: [.customLong("case-insensitive"), .customLong("ignore-case")])
    var isCaseInsensitive = false

    @Flag(name: [.customLong("diacritic-insensitive"), .customLong("ignore-diacritics")])
    var isDiacriticInsensitive = false

    enum Output: String, EnumerableFlag {

        case tree, list, leafCount = "leaf-count", count

    }

    @Flag
    var output = Output.tree

}

extension SearchPathCLI {

    func run() throws {
        _runAsyncMain { try await run() }
    }

    func run() async throws {
        do {
            try await search()
        }

        catch let invalidDirectory as DirectoryTree.InvalidDirectory {
            print("Invalid path: \(invalidDirectory.url.path)")
        }

        catch is SearchPath.InvalidPattern {
            print("Invalid pattern")
        }

        catch let invalidComponent as SearchPath.InvalidComponent {
            print("Invalid component: \(invalidComponent.content)")
        }
    }

    func search() async throws {
        guard let searchPath = SearchPath(string: pattern) else { throw SearchPath.InvalidPattern() }

        let directoryTree = try await SearchManager.shared.search(directoryTrees: directoryTrees, searchPath: searchPath, isRelative: isRelative, options: options)

        switch output {
        case .tree:
            print(directoryTree.compact)

        case .list:
            for url in directoryTree.urls {
                print(url.path)
            }

        case .leafCount:
            print(directoryTree.leafCount)

        case .count:
            print(directoryTree.urls.count)
        }
    }

}

extension SearchPathCLI {

    var urls: Array<URL> {
        paths.isEmpty ? [.currentDirectory] : paths.map(URL.init(fileURLWithPath:))
    }

    var directoryTrees: Array<DirectoryTree> {
        get throws { try urls.map(DirectoryTree.resolveDirectory(url:)) }
    }

    var options: SearchManager.Options {
        [
            isRegularExpression ? .regularExpression : [],
            isCompleteMatch ? .completeMatch : [],
            isCaseInsensitive ? .caseInsensitive : [],
            isDiacriticInsensitive ? .diacriticInsensitive : []
        ]
    }

}
