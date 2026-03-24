import SwiftUI


// MARK: - Title


struct WindowTitleKey: PreferenceKey {
    
    static var defaultValue: [String] { [] }
    
    static func reduce(value: inout [String], nextValue: () -> [String]) {
        value.append(contentsOf: nextValue())
    }
    
}


public extension View {
    
    func windowTitle(_ title: String) -> some View {
        preference(key: WindowTitleKey.self, value: [title])
    }
    
}
