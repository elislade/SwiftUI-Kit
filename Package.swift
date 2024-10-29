// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SwiftUIKit",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "SwiftUIKit", targets: ["SwiftUIKit"]),
        .library(name: "SwiftUICore", targets: ["SwiftUICore"]),
        .library(name: "SwiftUIPresentation", targets: ["SwiftUIPresentation"]),
        .library(name: "SwiftUINav", targets: ["SwiftUINav"]),
        .library(name: "SwiftUIMenu", targets: ["SwiftUIMenu"]),
        .library(name: "SwiftUIFont", targets: ["SwiftUIFont"]),
        .library(name: "SwiftUIControls", targets: ["SwiftUIControls"]),
        .library(name: "SwiftUILayout", targets: ["SwiftUILayout"]),
        .library(name: "SwiftUIExamples", targets: ["SwiftUIExamples"]),
    ],
    targets: [
        .target(
            name: "SwiftUIKit",
            dependencies: [
                "SwiftUICore", "SwiftUIPresentation", "SwiftUINav",
                "SwiftUIMenu", "SwiftUIFont", "SwiftUIControls", "SwiftUILayout"
            ]
        ),
        .target(name: "SwiftUIExamples", dependencies: [ "SwiftUIKit"]),
        .target(name: "SwiftUICore", dependencies: []),
        .target(name: "SwiftUILayout", dependencies: ["SwiftUICore"]),
        .target(name: "SwiftUIFont", dependencies: ["SwiftUICore"]),
        .target(name: "SwiftUIControls", dependencies: ["SwiftUICore"]),
        .target(name: "SwiftUIPresentation", dependencies: ["SwiftUICore"]),
        .target(name: "SwiftUINav", dependencies: ["SwiftUICore", "SwiftUIPresentation"]),
        .target(name: "SwiftUIMenu", dependencies: ["SwiftUICore", "SwiftUIPresentation"]),
    ]
)
