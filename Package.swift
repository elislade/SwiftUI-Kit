// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "SwiftUIKit",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "SwiftUIKit", targets: ["SwiftUIKit"]),
        .library(name: "SwiftUIKitCore", targets: ["SwiftUIKitCore"]),
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
                "SwiftUIKitCore", "SwiftUIPresentation", "SwiftUINav",
                "SwiftUIMenu", "SwiftUIFont", "SwiftUIControls", "SwiftUILayout"
            ]
        ),
        .target(name: "SwiftUIExamples", dependencies: [ "SwiftUIKit"]),
        .target(name: "SwiftUIKitCore", dependencies: []),
        .target(name: "SwiftUILayout", dependencies: ["SwiftUIKitCore"]),
        .target(name: "SwiftUIFont", dependencies: ["SwiftUIKitCore"]),
        .target(name: "SwiftUIControls", dependencies: ["SwiftUIKitCore"]),
        .target(name: "SwiftUIPresentation", dependencies: ["SwiftUIKitCore"]),
        .target(name: "SwiftUINav", dependencies: ["SwiftUIKitCore", "SwiftUIPresentation"]),
        .target(name: "SwiftUIMenu", dependencies: ["SwiftUIKitCore", "SwiftUIPresentation"]),
    ]
)
