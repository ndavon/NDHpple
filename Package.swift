// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "NDHpple",
    products: [
        .library(
            name: "NDHpple",
            targets: ["NDHpple"])
    ],
    targets: [
        .target(
            name: "NDHpple"),
        .testTarget(
            name: "NDHppleTests",
            dependencies: ["NDHpple"]),
    ]
)
