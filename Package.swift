// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STBlueSDK",
    platforms: [
           .iOS(.v15),
           .macOS(.v12)
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
        .package(url: "https://github.com/ybrid/opus-swift.git", from: "0.8.0"),
        // MARK: - LOCAL STCore
        .package(path: "Packages/STCore")
        // MARK: - REMOTE STCore
        //.package(url: "https://github.com/PRG-SWP/iOS_Module_STCore.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "STBlueSDK",
            dependencies: [
                .product(name: "YbridOpus", package: "opus-swift"),
                // MARK: - LOCAL STCore
                .product(name: "STCore", package: "STCore")
                // MARK: - REMOTE STCore
                //.product(name: "STCore", package: "iOS_Module_STCore")
            ]),
        .testTarget(
            name: "STBlueSDKTests",
            dependencies: ["STBlueSDK"]),
    ]
)
