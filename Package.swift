// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Chat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ExyteChat",
            targets: ["ExyteChat"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/exyte/MediaPicker.git",
            from: "3.4.4"
        ),
        .package(
           url: "https://github.com/Giphy/giphy-ios-sdk",
           exact: "2.2.16"
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher",
            from: "8.5.0"
        ),
        .package(
            url: "https://github.com/exyte/AnchoredPopup.git",
            from: "1.1.3"
        ),
    ],
    targets: [
        .target(
            name: "ExyteChat",
            dependencies: [
                .product(name: "ExyteMediaPicker", package: "MediaPicker"),
                .product(name: "GiphyUISDK", package: "giphy-ios-sdk"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "AnchoredPopup", package: "AnchoredPopup")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ExyteChatTests",
            dependencies: ["ExyteChat"]),
    ],
    swiftLanguageModes: [.v5]
)
