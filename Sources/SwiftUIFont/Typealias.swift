

#if canImport(SwiftUI)

import SwiftUI
public typealias OpaqueFont = SwiftUI.Font
public typealias FontTransform = CGAffineTransform
public typealias FontURL = SwiftUI.URL

#else

public typealias OpaqueFont = Never
public typealias FontTransform = Never
public typealias FontURL = Never

#endif
