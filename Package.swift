// swift-tools-version: 5.5

import PackageDescription

let package = Package(
  name: "Omnibar",
  products: [
    .library(
      name: "Omnibar",
      targets: ["Omnibar"]),
    .library(
      name: "RxOmnibar",
      targets: ["RxOmnibar"]),
    .library(
      name: "RxOmnibar-Static",
      type: .static,
      targets: ["RxOmnibar"]),
    .library(
      name: "RxOmnibar-Dynamic",
      type: .dynamic,
      targets: ["RxOmnibar"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.6.0"),
  ],
  targets: [
    .target(
      name: "Omnibar",
      dependencies: []),
    .testTarget(
      name: "OmnibarTests",
      dependencies: ["Omnibar"]),

    .target(
      name: "RxOmnibar",
      dependencies: [
        "Omnibar",
        "RxSwift",
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxRelay", package: "RxSwift"),
      ]),
    .testTarget(
      name: "RxOmnibarTests",
      dependencies: [
        "RxOmnibar",
        .product(name: "RxTest", package: "RxSwift"),
      ]),
  ]
)
