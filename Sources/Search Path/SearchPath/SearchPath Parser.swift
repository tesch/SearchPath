//
// SearchPath Parser.swift
//
// Created by Marcel Tesch on 2021-10-05.
// Think different.
//

import ParserCombinators

extension SearchPath.Pattern {

    static var parser: Parser<SearchPath.Pattern> {
        .pattern
        .padding()
        .terminate()
    }

}

private extension Parser {

    static var component: Parser<SearchPath.Pattern.Component> {
        .content
        .fallback(to: .negation)
        .fallback(to: .union)
        .fallback(to: .intersection)
    }

    static var pattern: Parser<SearchPath.Pattern> {
        .separator.trailingPadding().flag()

        .join { isRoot in
            .component
            .collection(separatedBy: .separator.padding())
            .filter { components in isRoot ? true : (components.isEmpty == false) }

            .join { components in
                .separator.leadingPadding().flag()

                .map { isDirectory in
                    SearchPath.Pattern(isRoot: isRoot, components: components, isDirectory: isDirectory)
                }
            }
        }
    }

}

private extension Parser {

    static var content: Parser<SearchPath.Pattern.Component> {
        .substring { character in
            ["<", ">"].contains(character) || character.isWhitespace
        }
        .orEmpty()
        .join(to:
            .partialContent
            .fallback(to: .bracketedContent)
        )
        .chain()
        .transform { parser in
            .partialContent
            .join(to: parser.orEmpty())
            .fallback(to:
                .bracketedContent
                .join(to: parser)
            )
        }
        .map(String.init)
        .map(SearchPath.Pattern.Component.content)
    }

    static var negation: Parser<SearchPath.Pattern.Component> {
        .character("<")
        .joinRight(to: .pattern)
        .joinLeft(to: .character(">"))
        .map(SearchPath.Pattern.Component.negation)
    }

    static var intersection: Parser<SearchPath.Pattern.Component> {
        .patternCollection(openingBracket: "(", closingBracket: ")")
        .map(SearchPath.Pattern.Component.intersection)
    }

    static var union: Parser<SearchPath.Pattern.Component> {
        .patternCollection(openingBracket: "[", closingBracket: "]")
        .map(SearchPath.Pattern.Component.union)
    }

}

private extension Parser {

    static func patternCollection(openingBracket: Character, closingBracket: Character) -> Parser<Array<SearchPath.Pattern>> {
        .character(openingBracket).trailingPadding()
        .joinRight(to:
            .pattern
            .collection(separatedBy: .character(",").padding(), allowingTrailingSeparator: true)
        )
        .joinLeft(to: .character(closingBracket).leadingPadding())
    }

}

private extension Parser {

    static var separator: Parser<Substring> { .substring(repeating: "/") }

    static var partialContent: Parser<Substring> {
        .substring { character in
            (["/", "\\", "<", ">", "(", ")", "[", "]", "{", "}", ","].contains(character) == false) && (character.isWhitespace == false)
        }
        .fallback(to: .escapedCharacter)
        .chain()
        .chain(with: .whitespace)
    }

    static var bracketedContent: Parser<Substring> {
        .substring { character in
            ["/", "\\", "(", ")", "[", "]", "{", "}"].contains(character) == false
        }
        .fallback(to: .escapedCharacter)
        .fallback(to: .lazy { .bracketedContent })
        .chain()
        .orEmpty()

        .transform { parser in
            .character("(").join(to: parser).join(to: .character(")"))
            .fallback(to: .character("[").join(to: parser).join(to: .character("]")))
            .fallback(to: .character("{").join(to: parser).join(to: .character("}")))
        }
    }

}
