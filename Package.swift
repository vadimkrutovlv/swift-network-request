// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-network-request",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftNetworkRequest",
            targets: ["SwiftNetworkRequest"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.3"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.9.2"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .macro(
            name: "SwiftNetworkRequestMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "SwiftNetworkRequest",
            dependencies: [
                "SwiftNetworkRequestMacros",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "SwiftNetworkRequestTests",
            dependencies: [
                "SwiftNetworkRequest",
                "SwiftNetworkRequestMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
