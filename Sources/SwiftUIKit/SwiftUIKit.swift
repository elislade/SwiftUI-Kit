@_exported import SwiftUI
@_exported import SwiftUIKitCore
@_exported import SwiftUIPresentation
@_exported import SwiftUINav
@_exported import SwiftUIMenu
@_exported import SwiftUIFont
@_exported import SwiftUILayout
@_exported import SwiftUIControls


// Override SwiftUI Types with SwiftUIKit types.
// These types share some of the same initialization signatures as SwiftUI's versions.
// To use the SwiftUI disambiguation you need to explicitly prefix it's type with the SwiftUI namespace.
// Eg. SwiftUI.Menu() will use the SwiftUI version over the kit implimentation.
public typealias Menu = SwiftUIMenu.Menu
public typealias Slider = SwiftUIControls.Slider
public typealias TextField = SwiftUIControls.TextField
public typealias KeyPress = SwiftUIKitCore.KeyPress
