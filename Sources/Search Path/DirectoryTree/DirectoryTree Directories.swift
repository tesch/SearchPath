//
// DirectoryTree Directories.swift
//
// Created by Marcel Tesch on 2021-11-09.
// Think different.
//

import Foundation

extension DirectoryTree {

    var directories: Self {
        Self(directory: directory.directories)
    }

}

private extension DirectoryTree.Directory {

    var directories: Self {
        Self(isLeaf: isLeaf, contents: contents.directories)
    }

}

private extension DirectoryTree.Contents {

    var directories: Self {
        var result: Self = [:]

        for (identifier, attribute) in self {
            switch attribute {
            case .fileOrDirectory:
                if let identifier = identifier.directory {
                    result.insert(.directory(isLeaf: true, contents: [:]), for: identifier)
                }

            case .directory(let directory):
                result.insert(.directory(directory.directories), for: identifier)
            }
        }

        return result
    }

}
