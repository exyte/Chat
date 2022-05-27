// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AssetsPicker",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "AssetsPicker",
            targets: ["AssetsPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AssetsPicker",
            dependencies: []
        ),
        .testTarget(
            name: "AssetsPickerTests",
            dependencies: ["AssetsPicker"]),
    ]
)
