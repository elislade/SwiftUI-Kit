// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "SwiftUIKit",
    platforms: [.macOS(.v13), .iOS(.v16), .macCatalyst(.v16), .tvOS(.v16), .watchOS(.v10)],
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
        .target(name: "SwiftUINav", dependencies: ["SwiftUIKitCore", "SwiftUIPresentation", "SwiftUIMenu"]),
        .target(name: "SwiftUIMenu", dependencies: ["SwiftUIKitCore", "SwiftUIPresentation", "SwiftUIControls"]),
    ],
    swiftLanguageModes: [ .version("6.2") ]
)
