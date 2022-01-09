//
// DirectoryTree Leaf Count.swift
//
// Created by Marcel Tesch on 2021-11-11.
// Think different.
//

import Foundation

public extension DirectoryTree {

    var leafCount: Int {
        directory.leafCount
    }

}

private extension DirectoryTree.Attribute {

    var leafCount: Int {
        switch self {
        case .fileOrDirectory:
            return 1

        case .directory(let directory):
            return directory.leafCount
        }
    }

}

private extension DirectoryTree.Directory {

    var leafCount: Int {
        (isLeaf ? 1 : 0) + contents.leafCount
    }

}

private extension DirectoryTree.Contents {

    var leafCount: Int {
        var result = 0

        for (_, attribute) in self {
            result += attribute.leafCount
        }

        return result
    }

}
