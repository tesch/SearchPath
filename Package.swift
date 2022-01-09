// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SearchPath",

    platforms: [.macOS(.v12)],

    products: [
        .library(name: "SearchPath", targets: ["SearchPath"]),
        .executable(name: "searchpath", targets: ["SearchPathCLI"])
    ],

    dependencies: [
        .package(url: "https://github.com/tesch/ParserCombinators", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
    ],

    targets: [
        .target(name: "SearchPath", dependencies: ["ParserCombinators"], path: "Sources/Search Path"),

        .executableTarget(name: "SearchPathCLI", dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"), "SearchPath"], path: "Sources/Search Path CLI")
    ]
)
