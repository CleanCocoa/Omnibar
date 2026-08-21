// swift-tools-version: 6.2

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
