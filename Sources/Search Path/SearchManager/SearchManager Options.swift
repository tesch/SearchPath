//
// SearchManager Options.swift
//
// Created by Marcel Tesch on 2021-10-26.
// Think different.
//

import Foundation

public extension SearchManager {

    struct Options: OptionSet, Hashable {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

    }

}

public extension SearchManager.Options {

    static let regularExpression = Self(rawValue: 1 << 0)

    static let completeMatch = Self(rawValue: 1 << 1)

    static let caseInsensitive = Self(rawValue: 1 << 2)

    static let diacriticInsensitive = Self(rawValue: 1 << 3)

}

extension SearchManager.Options {

    var isRegularExpression: Bool { contains(.regularExpression) }

    var isCompleteMatch: Bool { contains(.completeMatch) }

    var isCaseInsensitive: Bool { contains(.caseInsensitive) }

    var isDiacriticInsensitive: Bool { contains(.diacriticInsensitive) }

}

extension SearchManager.Options {

    var foldingOptions: String.CompareOptions {
        [
            (isCaseInsensitive && (isRegularExpression == false)) ? .caseInsensitive : [],
            isDiacriticInsensitive ? .diacriticInsensitive : [],
        ]
    }

}
