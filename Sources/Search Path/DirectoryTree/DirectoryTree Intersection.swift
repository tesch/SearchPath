//
// DirectoryTree Intersection.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

public extension DirectoryTree {

    func intersection(_ other: Self) -> Self {
        Self(directory: directory.intersection(other.directory))
    }

}

extension DirectoryTree.Attribute {

    func intersection(_ other: Self) -> Self {
        switch (self, other) {
        case (.fileOrDirectory, .fileOrDirectory):
            return .fileOrDirectory

        case (.fileOrDirectory, .directory(let directory)), (.directory(let directory), .fileOrDirectory):
            return .directory(isLeaf: directory.isLeaf, contents: [:])

        case (.directory(let directory), .directory(let otherDirectory)):
            return .directory(directory.intersection(otherDirectory))
        }
    }

}

extension DirectoryTree.Directory {

    func intersection(_ other: Self) -> Self {
        Self(isLeaf: isLeaf && other.isLeaf, contents: contents.intersection(other.contents))
    }

}

extension DirectoryTree.Contents {

    func intersection(_ other: Self) -> Self {
        var result: Self = [:]

        for (identifier, attribute) in self {
            result[identifier] = other[identifier]?.intersection(attribute)
        }

        return result
    }

}
