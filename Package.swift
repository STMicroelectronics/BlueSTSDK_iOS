// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STBlueSDK",
    platforms: [
           .iOS(.v13),
           .macOS(.v11)
       ],
    products: [
        .library(
            name: "STBlueSDK",
            targets: ["STBlueSDK"]),
    ],
    dependencies: [
        .package(url: "./Packages/iOS_Module_STCore", from: "0.0.0"),
        .package(url: "https://github.com/ybrid/opus-swift.git", from: "0.8.0")
    ],
    targets: [
        .target(
            name: "STBlueSDK",
            dependencies: [
                .product(name: "YbridOpus", package: "opus-swift"),
                .product(name: "STCore", package: "iOS_Module_STCore")
            ]),
        .testTarget(
            name: "STBlueSDKTests",
            dependencies: ["STBlueSDK"]),
    ]
)
