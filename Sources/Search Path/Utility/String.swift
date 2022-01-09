//
// String.swift
//
// Created by Marcel Tesch on 2021-11-12.
// Think different.
//

import Foundation

extension String.CompareOptions: Hashable {  }

extension String {

    var utf16Range: NSRange { NSRange(location: 0, length: utf16.count) }

    var foldingEscapedCharacters: String? {
        var result = ""

        var iterator = makeIterator()
        var nextCharacter = iterator.next()

        while let currentCharacter = nextCharacter {
            nextCharacter = iterator.next()

            if currentCharacter == "\\" {
                guard let character = nextCharacter else { return nil }

                result.append(character)

                nextCharacter = iterator.next()
            } else {
                result.append(currentCharacter)
            }
        }

        return result
    }

}
