// swift-tools-version:5.2

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
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Crane",
      dependencies: ["CraneURL", "CraneHTTP"]),
    .testTarget(
      name: "CraneTests",
      dependencies: ["Crane"]),
    .target(
      name: "CraneURL",
      dependencies: []),
    .testTarget(
      name: "CraneURLTests",
      dependencies: ["CraneURL"]),
    .target(
      name: "CraneHTTP",
      dependencies: []),
    .testTarget(
      name: "CraneHTTPTests",
      dependencies: ["CraneHTTP"]),
  ]
)
