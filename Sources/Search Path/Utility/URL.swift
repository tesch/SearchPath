//
// URL.swift
//
// Created by Marcel Tesch on 2021-10-25.
// Think different.
//

import Foundation

extension URL {

    static let rootDirectory = URL(fileURLWithPath: "/")

    static let homeDirectory = FileManager.default.homeDirectoryForCurrentUser

}

extension URL {

    var isDirectory: Bool? {
        try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory
    }

    var directory: URL? {
        guard let url = try? URL(resolvingAliasFileAt: self), url.isDirectory == true else { return nil }

        return url
    }

}

extension URL {

    func contains(_ url: URL) -> Bool {
        var iterator = pathComponents.makeIterator()

        for pathComponent in url.pathComponents {
            guard pathComponent == iterator.next() else { return false }
        }

        return true
    }

}

extension URL {

    typealias Contents = Array<URL>

    func contents(includingHiddenFilesAndDirectories: Bool) -> Contents? {
        let options: FileManager.DirectoryEnumerationOptions = includingHiddenFilesAndDirectories ? [] : [.skipsHiddenFiles]

        return try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [], options: options)
    }

}
