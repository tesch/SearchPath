//
// DirectoryTree Description.swift
//
// Created by Marcel Tesch on 2021-11-08.
// Think different.
//

import Foundation

private let offset = 4

extension DirectoryTree: CustomStringConvertible {

    public var description: String {
        "/" + directory.description(indentedBy: 0)
    }

}

private extension DirectoryTree.Directory {

    func description(indentedBy level: Int) -> String {
        if isLeaf {
            return contents.isEmpty ? "" : ("./" + contents.description(indentedBy: level))
        }

        return contents.description(indentedBy: level)
    }

}

private extension DirectoryTree.Contents {

    func description(indentedBy level: Int) -> String {
        if count == 0 { return "[]" }
        if count == 1 { return descriptions(indentedBy: level)[0] }

        return "[\n"

            + descriptions(indentedBy: level + offset).map { line in
                String(repeating: " ", count: level + offset) + line
            }.joined(separator: ",\n")

            + "\n" + String(repeating: " ", count: level) + "]"
    }

    func descriptions(indentedBy level: Int) -> Array<String> {
        map { identifier, attribute in
            switch attribute {
            case .fileOrDirectory:
                return identifier.title

            case .directory(let directory):
                return identifier.title + "/" + directory.description(indentedBy: level)
            }
        }.sorted { left, right in
            left.localizedStandardCompare(right) == .orderedAscending
        }
    }

}
