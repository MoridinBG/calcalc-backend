// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "calcalc-backend",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.4.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor/mysql-provider", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/jwt.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.2.0"))
    ],
    targets: [
        .target(name: "App",
                dependencies: ["Vapor", "FluentProvider", "MySQLProvider", "AuthProvider", "JWT"],
                exclude: [
                    "Config",
                    "Database",
                    "Localization",
                    "Public",
                    "Resources",
                    ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

