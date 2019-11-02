// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HatTip",
    platforms: [
       .macOS(.v10_14), .iOS(.v11),
    ],
    products: [
        .library(
            name: "HatTip",
            targets: ["HatTip"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "HatTip",
            dependencies: []
        ),
        .testTarget(
            name: "HatTipTests",
            dependencies: ["HatTip"]
        ),
    ]
)
