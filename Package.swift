// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NKJMovieComposer",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "NKJMovieComposer",
            targets: ["NKJMovieComposer"]
        ),
    ],
    targets: [
        .target(
            name: "NKJMovieComposer",
            path: "Sources/Classes"
        ),
        .testTarget(
            name: "NKJMovieComposerTests",
            dependencies: ["NKJMovieComposer"],
            path: "NKJMovieComposerTests",
            resources: [.copy("Resources")]
        ),
    ]
)
