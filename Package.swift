// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Crane",
  platforms: [.iOS(.v12), .tvOS(.v12), .macOS(.v10_14), .watchOS(.v5)],
  products: [
    .library(
      name: "Crane",
      targets: ["Crane"]),
    .library(
      name: "CraneURL",
      targets: ["CraneURL"]),
    .library(
      name: "CraneHTTP",
      targets: ["CraneHTTP"]),
    .library(
      name: "CraneParameters",
      targets: ["CraneParameters"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Crane",
      dependencies: ["CraneParameters", "CraneURL", "CraneHTTP"]),
    .testTarget(
      name: "CraneTests",
      dependencies: ["Crane"]),
    .target(
      name: "CraneURL",
      dependencies: ["CraneParameters"]),
    .testTarget(
      name: "CraneURLTests",
      dependencies: ["CraneURL"]),
    .target(
      name: "CraneHTTP",
      dependencies: ["CraneParameters"]),
    .testTarget(
      name: "CraneHTTPTests",
      dependencies: ["CraneHTTP"]),
    .target(
      name: "CraneParameters",
      dependencies: []),
    .testTarget(
      name: "CraneParametersTests",
      dependencies: ["CraneParameters"]),
  ]
)
