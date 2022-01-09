//
// DirectoryTree Compact.swift
//
// Created by Marcel Tesch on 2021-12-06.
// Think different.
//

import Foundation

public extension DirectoryTree {

    var compact: Self {
        Self(directory: directory.compact)
    }

}

private extension DirectoryTree.Attribute {

    var compact: Self? {
        switch self {
        case .fileOrDirectory:
            return .fileOrDirectory

        case .directory(let directory):
            let directory = directory.compact

            return directory.isEmpty ? nil : .directory(directory)
        }
    }

}

private extension DirectoryTree.Directory {

    var compact: Self {
        Self(isLeaf: isLeaf, contents: contents.compact)
    }

}

private extension DirectoryTree.Contents {

    var compact: Self {
        compactMapValues(\.compact)
    }

}
