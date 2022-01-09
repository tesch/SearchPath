`SearchPath` defines a concise syntax to formulate hierarchical file searches, using set operations, string-matching, and regular expressions.

## Overview

A search pattern defines a set of file paths which fullfill a given set of criteria. Such criteria are composed of string patterns, as well as unions `[...]`, intersections `(...)`, and negations `<...>` thereof.

```
~/[
    (foo, <bar>)/baz,
    lorem/[
        ipsum/dolor,
        sit/amet/..
    ]
]/.../
\.txt$
```

## Component Separators

Individual components of a search pattern are usually separated by a single slash `/`. A separator may also be comprised of multiple consecutive slashes, to facilitate the convenient construction of search patterns via string concatenation, i.e. `"foo/" + "/bar" == "foo//bar" == "foo/bar"`.

Importantly, all surrounding whitespace before or after the separating slashes is interpreted as part of the separator itself and *not* as part of the pattern, i.e. `"foo / bar" == "foo/\nbar" == "foo/bar"`. This allows for complex patterns to be formatted in a more readable fashion by splitting them across multiple lines. In cases where a pattern is intended to include leading or trailing whitespace, explicit escaping is required, i.e. `"foo/\ bar" != "foo/ bar"`.

## Unions and Intersections

Multiple search patterns may be combined by forming the union or intersection of their respective results.

Unions are expressed as comma-separated lists of subpatterns enclosed within square brackets, i.e. `[foo, bar]`, meaning anything that matches either `foo` *or* `bar`. Analogously, intersections are enclosed within parentheses, i.e. `(foo, bar)`, meaning anything that matches both `foo` *and* `bar`.

Unions and intersections may contain complex subpatterns with arbitrarily many components, e.g. `[foo/bar, baz]` and `[(foo, bar), baz]` are valid patterns.

Any subpattern that begins and ends with a matching pair of either `[]` or `()` is interpreted as a union/intersection expression, unless explicitly escaped, i.e. `"\(foo\)" != "(foo)"`. A string pattern may not begin and end with a matching pair of unescaped curly brackets `{}` as well, as they are reserved for future use. String patterns are otherwise free to include unescaped brackets, as long as they occur in matching pairs. Unmatched brackets always need to be escaped.

In cases where a string pattern consists of a regular expression containing only a single character set, an explicit disambiguation from a single-element union expression is required, i.e. `"[abc]" != "\[abc\]" != "[abc]{1}"`.

As unions and intersections use commas `,` to separate their subpatterns, it is generally required to escape any comma that is intended to be part of a string pattern, i.e. `foo, bar` is an invalid pattern by itself, it needs to be `foo\, bar`.

Commas don't need to be explicitly escaped if they occur within a matched pair of brackets embedded within a string pattern, to allow for the correct use of limited repetition within regular expressions, i.e. `foo{3,5}` is a valid pattern.

## Negations

Patterns may be negated by enclosing them within angle brackets `<>`, i.e. `<foo>`, meaning anything that doesn't match `foo`. Multiple nested negations are legal, i.e. `"<<foo>>" == "foo"`. If a negation is applied to a pattern that has multiple components, then each component is negated individually, i.e. `"<foo/bar>" == "<foo>/<bar>"`.

Note that the negation of a union becomes an intersection of negations and that a negation of an intersection becomes a union of negations, i.e. `"<[foo, bar]>" == "(<foo>, <bar>)"` and `"<(foo, bar)>" == "[<foo>, <bar>]"`.

A string pattern may not begin or end with an unescaped angle bracket.

## Dot Operators

The `.`, `..`, and `...` operators afford the ability to match the current set of file paths, the parent directories of the current set of file paths, and the recursively listed contents of the current set of file paths, respectively.

The single dot `.` operator acts as a no-op in most circumstances, i.e. `"foo/./bar" == "foo/bar"`. A common use case is to apply it in conjuction with a union expression to include a specific set of potential parent directories in the final result, i.e. `"foo/[., bar]" == "[foo, foo/bar]"`.

Importantly, the double dot `..` operator *doesn't* implicity remove the previous component from the pattern, i.e. `"foo/bar/.." != "foo/"`. The former matches directories that match `foo` which contain at least one file or directory matching `bar`, whereas the latter only matches directories matching `foo`.

The triple dot `...` operator recursively matches everything that is contained within the hierarchies of all currently matched directories. It is therefore a potentially expensive operation and should be used with care. The resulting set of file paths includes its starting point, i.e. `"foo/..." == "foo/[., ...]"`. Following `...` with other components is legal, e.g. `.../foo`.

Note that dot operators are unaffected by negations, i.e. `"foo/<./>" == "foo/./" == "foo/"`.

## Symbolic Links and Aliases

Symlinks and aliases *to directories* are automatically resolved if they are explicitly matched *as directories*, i.e. the result of `foo` may contain unresolved links, whereas the result of `foo/` only contains fully resolved paths to directories.

Links to plain files always remain unresolved.

The `...` operator includes links to directories in its recursive search, though it does not traverse circular links. If a link that resolves to a parent directory of the current search directory is encountered, then the search for that particular subtree is stopped and the target of the circular link is not included in the result, though the link itself is.

Note that this does not preclude the `...` operator from matching certain paths multiple times though, as any path may be reachable through an arbitrary number of non-circular links, all of which are searched.

## API

Evaluating a search pattern is straightforward:

```swift
guard let searchPath = SearchPath(string: #".../([foo, bar], \.txt$)"#) else { ... }

let result = try await SearchManager.shared.search(directoryTree: .home, searchPath: searchPath, options: [.regularExpression, .caseInsensitive])

for url in result.urls {
    print(url.path)
}
```

A `SearchPath` struct represents a given search pattern. Its initializer returns `nil` if the given pattern is invalid. Note that the initializer succeeding isn't necessarily a guarantee that the search pattern can be successfully evaluated, as it may still contain invalid regular expressions or string patterns ending with a single backslash, which are not caught by the parser.

`SearchManager` objects are responsible for conducting the actual search of the file system. They manage an internal cache of partial search results that allows for the efficient evaluation of multiple similar search patterns in quick succession, enabling responsive behavior in applications where a search pattern is provided by the user via a text field, for example. The cache must be manually invalidated whenever there is reason to believe that the contents of underlying file system might have changed.

A search pattern may be evaluated exclusively in relation to the given initial set of directory paths by passing `isRelative: true` to the `search` method. This prevents the matching of any absolute paths in cases where the pattern or one of its subpatterns begins with either a slash `/` or tilde `~`.

Evaluation of a search pattern may be customized with the following options:
* `.regularExpression`: Interprets all string patterns as regular expressions.
* `.completeMatch`: Requires all file and directory names to be matched in full.
* `.caseInsensitive`: Ignores case.
* `.diacriticInsensitive`: Ignores diacritics.

All permutations of options are valid.

The search API is `async`, because searches are conducted in parallel.

The resulting set of file paths is represented by a `DirectoryTree` struct, which preserves the hierarchical structure in which the matched paths are organized within the file system.

## CLI

Alternatively, you can search right from the command line as well:

```
searchpath ".../([foo, bar], \.txt$)" ~ --regex --case-insensitive --list
```

Take a look at `searchpath --help` for more details.

## Future

`SearchPath` is still a work in progress. It's lacking key features, it probably has bugs, and its design is likely to have blind spots that I haven't even thought of. So it might change, hopefully for the better.

Here is a list of features that I think would make for useful additions in the future:
* Allow a search pattern to be annotated with comments. It is currently only possible to include comments within regular expressions, i.e. `"(?x)foo#bar" == "foo(?#bar)" == "foo"`, but that is probably not enough in the long run.
* Include an option to not automatically resolve links to directories and/or to resolve links to plain files.
* Include an option to only match *files*. Exclusively matching *directories* is possible by terminating a search pattern with a slash `/`, an analogous operation to exclusively match files would thus be appropriate.
* Include an option to consider hidden files as well. Hidden files are currently ignored.
* Improve error messages for invalid patterns. Understanding why a given pattern doesn't parse isn't always self-explanatory, the parser should be able to provide more help in that regard.
