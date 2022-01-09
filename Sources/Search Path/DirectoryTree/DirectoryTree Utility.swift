//
// DirectoryTree Utility.swift
//
// Created by Marcel Tesch on 2021-11-24.
// Think different.
//

import Foundation

extension DirectoryTree.Identifier {

    var directory: Self? {
        url.directory.map { url in Self(title: title, url: url) }
    }

    init(url: URL) {
        self.init(title: url.lastPathComponent, url: url)
    }

}

extension DirectoryTree.Attribute {

    static func directory(isLeaf: Bool, contents: DirectoryTree.Contents) -> Self {
        .directory(DirectoryTree.Directory(isLeaf: isLeaf, contents: contents))
    }

}

extension DirectoryTree.Directory {

    static let leaf = Self(isLeaf: true, contents: [:])

    init(isLeaf: Bool, urls: Array<URL>) {
        self.init(isLeaf: isLeaf, contents: [:])

        let identifiers = urls.map(DirectoryTree.Identifier.init(url:))

        for identifier in identifiers {
            contents[identifier] = .fileOrDirectory
        }
    }

}
