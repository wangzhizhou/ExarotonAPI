// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExarotonAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .visionOS(.v1),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "ExarotonHTTP", targets: ["ExarotonHTTP"]),
        .library(name: "ExarotonWebSocket", targets: ["ExarotonWebSocket"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.0.2"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.8"),
        .package(url: "https://github.com/flight-school/anycodable.git", from: "0.6.7"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4"),
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ExarotonHTTP",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ], plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .testTarget(
            name: "ExarotonHTTPTests",
            dependencies: [
                "ExarotonHTTP",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .target(
            name: "ExarotonWebSocket",
            dependencies: [
                .product(name: "Starscream", package: "starscream"),
                .product(name: "AnyCodable", package: "AnyCodable"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "ExarotonWebSocketTests",
            dependencies: [
                "ExarotonWebSocket",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .executableTarget(
            name: "HTTPUsageDemo",
            dependencies: [
                "ExarotonHTTP",
            ]
        ),
        .executableTarget(
            name: "WebSocketUsageDemo",
            dependencies: [
                "ExarotonWebSocket",
            ]
        ),
    ]
)
