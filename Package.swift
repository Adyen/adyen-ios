// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adyen-ios",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Adyen",
            targets: ["DropIn"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: "./Core", from: "3.6.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "DropIn",
                dependencies: ["Card"],
                path: "./AdyenDropIn"),
        .target(name: "Card",
                dependencies: ["Core"],
                path: "./AdyenCard"),
        .target(name: "Core",
                dependencies: [],
                path: "./Adyen"),
        .testTarget(name: "AdyenTests", dependencies: [
            .target(name: "DropIn"),
            .target(name: "Card"),
            .target(name: "Core")],
                    path: "./AdyenTests")
    ]
)
