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
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "STBlueSDK",
            targets: ["STBlueSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // // .package(url: /* package url */, from: "1.0.0")
        .package(path: "./Packages/STCore"),
        .package(url: "https://github.com/ybrid/opus-swift.git", from: "0.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "STBlueSDK",
            dependencies: [
                .product(name: "YbridOpus", package: "opus-swift"),
                .product(name: "STCore", package: "STCore")
            ]),
        .testTarget(
            name: "STBlueSDKTests",
            dependencies: ["STBlueSDK"]),
    ]
)
