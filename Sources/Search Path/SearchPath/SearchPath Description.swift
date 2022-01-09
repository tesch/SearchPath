//
// SearchPath Description.swift
//
// Created by Marcel Tesch on 2021-10-15.
// Think different.
//

private let offset = 4

extension SearchPath: CustomStringConvertible {

    public var description: String {
        pattern.description(indentedBy: offset)
    }

}

private extension SearchPath.Pattern {

    func description(indentedBy level: Int) -> String {
        (isRoot ? "/" : "") + components.map { component in
            component.description(indentedBy: level)
        }.joined(separator: "/") + (isDirectory ? "/" : "")
    }

}

private extension SearchPath.Pattern.Component {

    func description(indentedBy level: Int) -> String {
        switch self {
        case .content(let content):
            return content

        case .negation(let pattern):
            return "<" + pattern.description(indentedBy: level) + ">"

        case .union(let patterns):
            return "[\n" + patterns.map { pattern in
                let level = level + offset

                return String(repeating: " ", count: level) + pattern.description(indentedBy: level)
            }.joined(separator: ",\n") + "\n" + String(repeating: " ", count: level) + "]"

        case .intersection(let patterns):
            return "(" + patterns.map { pattern in
                pattern.description(indentedBy: level)
            }.joined(separator: ", ") + ")"
        }
    }

}
