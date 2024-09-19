// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ExyteChat",
            targets: ["ExyteChat"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/siteline/swiftui-introspect",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/exyte/MediaPicker.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/exyte/FloatingButton",
            from: "1.2.2"
        ),
        .package(
            url: "https://github.com/exyte/ActivityIndicatorView",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "ExyteChat",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "ExyteMediaPicker", package: "MediaPicker"),
                .product(name: "FloatingButton", package: "FloatingButton"),
                .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView")
            ]
        ),
        .testTarget(
            name: "ExyteChatTests",
            dependencies: ["ExyteChat"]),
    ]
)
