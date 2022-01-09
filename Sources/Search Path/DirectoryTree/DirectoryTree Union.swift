//
// DirectoryTree Union.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

public extension DirectoryTree {

    func union(_ other: Self) -> Self {
        Self(directory: directory.union(other.directory))
    }

}

extension DirectoryTree.Attribute {

    func union(_ other: Self) -> Self {
        switch (self, other) {
        case (.fileOrDirectory, .fileOrDirectory):
            return .fileOrDirectory

        case (.fileOrDirectory, .directory(let directory)), (.directory(let directory), .fileOrDirectory):
            return .directory(isLeaf: true, contents: directory.contents)

        case (.directory(let directory), .directory(let otherDirectory)):
            return .directory(directory.union(otherDirectory))
        }
    }

}

extension DirectoryTree.Directory {

    func union(_ other: Self) -> Self {
        Self(isLeaf: isLeaf || other.isLeaf, contents: contents.union(other.contents))
    }

}

extension DirectoryTree.Contents {

    mutating func insert(_ attribute: DirectoryTree.Attribute, for identifier: DirectoryTree.Identifier) {
        self[identifier] = self[identifier]?.union(attribute) ?? attribute
    }

    func union(_ other: Self) -> Self {
        var result = self

        for (identifier, attribute) in other {
            result.insert(attribute, for: identifier)
        }

        return result
    }

}
