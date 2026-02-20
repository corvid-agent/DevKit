// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DevKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DevKit", targets: ["DevKit"])
    ],
    targets: [
        .executableTarget(
            name: "DevKit",
            path: "Sources/DevKit"
        ),
        .testTarget(
            name: "DevKitTests",
            dependencies: ["DevKit"],
            path: "Tests/DevKitTests"
        )
    ]
)
