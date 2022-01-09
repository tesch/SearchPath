//
// DirectoryTree Parents.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

extension DirectoryTree {

    var parents: Self {
        Self(directory: directory.parents(isRoot: true))
    }

}

private extension DirectoryTree.Directory {

    var parents: Self {
        parents(isRoot: false)
    }

    func parents(isRoot: Bool) -> Self {
        var result = Self(isLeaf: isRoot ? isLeaf : false, contents: [:])

        for (identifier, attribute) in contents {
            switch attribute {
            case .fileOrDirectory:
                result.isLeaf = true

            case .directory(let directory):
                if directory.isLeaf { result.isLeaf = true }

                result.contents[identifier] = .directory(directory.parents)
            }
        }

        return result
    }

}
