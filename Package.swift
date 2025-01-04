// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Omnibar",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "Omnibar",
            targets: ["Omnibar"]),
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
    ]
)
