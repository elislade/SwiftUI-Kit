import SwiftUI

#if canImport(AppKit)

struct WindowRootView<Content: View>: View {
    
    @State private var radius: CGFloat = SwiftUIWindow.defaultRadius
    @ObservedObject var state: WindowState
    
    let content: Content
    
    var body: some View {
        content
            .containerShape(RoundedRectangle(cornerRadius: radius))
            .environment(\._windowIsKey, state.isKey)
            .onPreferenceChange(WindowCornerRadiusKey.self){ pendingDestinationValues in
                state.set(radius: pendingDestinationValues.last)
                radius = pendingDestinationValues.last ?? SwiftUIWindow.defaultRadius
            }
            .onAppear(perform: state.onappear)
    }
    
}

#endif
