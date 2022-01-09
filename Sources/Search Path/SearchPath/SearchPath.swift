//
// SearchPath.swift
//
// Created by Marcel Tesch on 2021-10-05.
// Think different.
//

import Foundation

public struct SearchPath {

    let pattern: Pattern

    public init?(string: String) {
        guard let (pattern, _) = try? Pattern.parser.parse(string) else { return nil }

        self.pattern = pattern
    }

}

extension SearchPath {

    struct Pattern: Hashable {

        let isRoot: Bool

        let components: Array<Component>

        let isDirectory: Bool

    }

}

extension SearchPath.Pattern {

    enum Component: Hashable {

        case content(String)

        case negation(SearchPath.Pattern)

        case union(Array<SearchPath.Pattern>)

        case intersection(Array<SearchPath.Pattern>)

    }

}
