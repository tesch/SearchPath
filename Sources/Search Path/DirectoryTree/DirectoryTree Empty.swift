//
// DirectoryTree Empty.swift
//
// Created by Marcel Tesch on 2021-12-09.
// Think different.
//

import Foundation

public extension DirectoryTree {

    static let empty = Self(directory: .empty)

    var isEmpty: Bool {
        directory.isEmpty
    }

}

extension DirectoryTree.Directory {

    static let empty = Self(isLeaf: false, contents: [:])

    var isEmpty: Bool {
        (isLeaf == false) && contents.isEmpty
    }

}
