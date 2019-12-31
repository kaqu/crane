// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Crane",
  platforms: [.iOS(.v12), .tvOS(.v12), .macOS(.v10_14), .watchOS(.v5)],
  products: [
    .library(
      name: "Crane",
      targets: ["Crane"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Crane",
      dependencies: []),
    .testTarget(
      name: "CraneTests",
      dependencies: ["Crane"]),
  ]
)
