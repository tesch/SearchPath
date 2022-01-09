//
// DirectoryTree.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

public struct DirectoryTree: Hashable {

    var directory: Directory

}

extension DirectoryTree {

    struct Identifier: Hashable {

        let title: String

        let url: URL

    }

    enum Attribute: Hashable {

        case fileOrDirectory

        case directory(Directory)

    }

    struct Directory: Hashable {

        var isLeaf: Bool

        var contents: Contents

    }

    typealias Contents = Dictionary<Identifier, Attribute>

}

extension DirectoryTree {

    static let root = Self(directory: .leaf)

    static let home = directory(url: .homeDirectory)

}

public extension DirectoryTree {

    static func resolveDirectory(url: URL) throws -> Self {
        try directory(url: url) { url in
            guard let url = url.directory else { throw InvalidDirectory(url: url) }

            return url
        }
    }

    static func directory(url: URL) -> Self {
        directory(url: url) { url in url }
    }

}

private extension DirectoryTree {

    static func directory(url: URL, _ block: (URL) throws -> URL) rethrows -> Self {
        try url.pathComponents.dropFirst().reduce([]) { (identifiers: Array<Identifier>, component: String) in
            let url = (identifiers.last?.url ?? .rootDirectory).appendingPathComponent(component)

            return identifiers + [Identifier(title: component, url: try block(url))]
        }

        .reversed().reduce(.root) { (result: Self, identifier: Identifier) in
            let contents: Contents = [identifier: .directory(result.directory)]

            return Self(directory: Directory(isLeaf: false, contents: contents))
        }
    }

}
