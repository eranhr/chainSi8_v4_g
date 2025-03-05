// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Si8c_v3.1",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/Kitura-redis.git", from: "2.1.1")
    ],
    targets: [
        .target(
            name: "Si8c_v3.1",
            dependencies: [
                .product(name: "SwiftRedis", package: "Kitura-redis")
            ],
            path: "Si8c_v3.1"
        )
    ]
) 