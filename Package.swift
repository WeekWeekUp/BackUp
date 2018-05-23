// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModuleSearch",
    products: [
        .executable(name: "ModuleMap", targets: ["ModuleSearch"]),
        ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/kylef/PathKit", from: "0.9.0"),
        .package(url:"https://github.com/kylef/Spectre.git", .upToNextMinor(from:"0.8.0")),
        .package(url:"https://github.com/AceSha/XcodeEdit", .upToNextMinor(from:"2.0.1")),
        ],
    targets: [
        .target(name: "ModuleSearch", dependencies: ["ModuleSearchCore"]),
        .target(name: "ModuleSearchCore", dependencies: ["Commander", "PathKit", "Spectre", "XcodeEdit"]),
//        .testTarget(name: "ModuleSearchCoreTests", dependencies: ["ModuleSearchCore"]),
        ],

    swiftLanguageVersions: [4]
)
