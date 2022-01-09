//
// NSRegularExpression.swift
//
// Created by Marcel Tesch on 2021-11-12.
// Think different.
//

import Foundation

extension NSRegularExpression {

    func completelyMatches(_ string: String) -> Bool {
        firstMatch(in: string, range: string.utf16Range)?.range == string.utf16Range
    }

    func partiallyMatches(_ string: String) -> Bool {
        firstMatch(in: string, range: string.utf16Range) != nil
    }

}
