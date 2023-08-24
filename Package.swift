// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chat",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Chat",
            targets: ["Chat"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/siteline/SwiftUI-Introspect.git",
            from: "0.1.4"
        ),
        .package(
            url: "https://github.com/exyte/MediaPicker.git",
            from: "1.2.4"
        ),
        .package(
            url: "https://github.com/exyte/FloatingButton",
            from: "1.0.1"
        ),
        .package(
            url: "https://github.com/exyte/ActivityIndicatorView",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "Chat",
            dependencies: [
                .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .product(name: "ExyteMediaPicker", package: "MediaPicker"),
                .product(name: "FloatingButton", package: "FloatingButton"),
                .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView")
            ]
        ),
        .testTarget(
            name: "ChatTests",
            dependencies: ["Chat"]),
    ]
)
