// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "com.awareframework.ios.sensor.device",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "com.awareframework.ios.sensor.device",
            targets: [
                "com.awareframework.ios.sensor.device"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/awareframework/com.awareframework.ios.core.git", from: "1.1.1")
    ],
    targets: [
        .target(
            name: "com.awareframework.ios.sensor.device",
            dependencies: [
                .product(name: "com.awareframework.ios.core", package: "com.awareframework.ios.core", condition: .when(platforms: [.iOS]))
            ],
            path: "Sources/com.awareframework.ios.sensor.device"
        ),
        .testTarget(
            name: "com.awareframework.ios.sensor.deviceTests",
            dependencies: ["com.awareframework.ios.core", "com.awareframework.ios.sensor.device"]
        )
    ],
    swiftLanguageModes: [.v5]
)
