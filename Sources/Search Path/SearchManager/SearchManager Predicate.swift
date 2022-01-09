//
// SearchManager Predicate.swift
//
// Created by Marcel Tesch on 2021-12-12.
// Think different.
//

import Foundation

extension SearchManager {

    struct Predicate: Hashable {

        private let pattern: Pattern

        private let foldingOptions: String.CompareOptions

        private let isCompleteMatch: Bool

    }

}

private extension SearchManager.Predicate {

    enum Pattern: Hashable {

        case string(String)

        case regex(NSRegularExpression)

    }

}

extension SearchManager.Predicate {

    init?(string: String, options: SearchManager.Options) {
        foldingOptions = options.foldingOptions
        isCompleteMatch = options.isCompleteMatch

        let string = string.folding(options: foldingOptions, locale: nil)

        if options.isRegularExpression {
            let options: NSRegularExpression.Options = options.isCaseInsensitive ? [.caseInsensitive]: []

            guard let regex = try? NSRegularExpression(pattern: string, options: options) else { return nil }

            pattern = .regex(regex)
        } else {
            guard let string = string.foldingEscapedCharacters else { return nil }

            pattern = .string(string)
        }
    }

    func matches(_ string: String) -> Bool {
        let string = string.folding(options: foldingOptions, locale: nil)

        switch (pattern, isCompleteMatch) {
        case (.string(let other), true):
            return string == other

        case (.string(let other), false):
            return string.contains(other)

        case (.regex(let regex), true):
            return regex.completelyMatches(string)

        case (.regex(let regex), false):
            return regex.partiallyMatches(string)
        }
    }

}
