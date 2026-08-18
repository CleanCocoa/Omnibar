// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Omnibar",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Omnibar",
            targets: ["Omnibar"]),
        .library(
            name: "AsyncOmnibar",
            targets: ["AsyncOmnibar"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Omnibar",
            dependencies: []),
        .testTarget(
            name: "OmnibarTests",
            dependencies: ["Omnibar"]),
        .target(
            name: "AsyncOmnibar",
            dependencies: ["Omnibar"]),
        .testTarget(
            name: "AsyncOmnibarTests",
            dependencies: ["AsyncOmnibar"]),
    ]
)
