// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaBrowser",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MediaBrowser",
            targets: ["MediaBrowser"]),
    ],
    dependencies: [
        .package(url: "https://github.com/powerplay-developers/iOS-UXPagerView", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MediaBrowser",
            dependencies: [.product(name: "UXPagerView", package: "iOS-UXPagerView")],
            path: "Sources",
            resources: [
                .process("MediaBrowser/Resources/VideoControlsOverlayView.xib"),
                .process("MediaBrowser/Resources/MediaBrowserAssets.xcassets")
            ]
        ),
    ]
)
