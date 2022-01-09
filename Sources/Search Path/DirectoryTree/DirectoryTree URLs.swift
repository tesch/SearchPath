//
// DirectoryTree URLs.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

public extension DirectoryTree {

    var urls: Set<URL> {
        Set((directory.isLeaf ? [.rootDirectory] : []) + directory.contents.urls)
    }

}

private extension DirectoryTree.Contents {

    var urls: Array<URL> {
        var result: Array<URL> = []

        for (identifier, attribute) in self {
            switch attribute {
            case .fileOrDirectory:
                result.append(identifier.url)

            case .directory(let directory):
                if directory.isLeaf { result.append(identifier.url) }

                result.append(contentsOf: directory.contents.urls)
            }
        }

        return result
    }

}
