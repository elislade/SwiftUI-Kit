import SwiftUI

#if canImport(AppKit)

struct WindowRootView<Content: View>: View {
    
    @State private var radius: CGFloat = 0
    @ObservedObject var state: WindowState
    
    let content: Content
    
    var body: some View {
        content
            .containerShape(RoundedRectangle(cornerRadius: radius))
            .environment(\._windowIsKey, state.isKey)
            .onPreferenceChange(WindowCornerRadiusKey.self){ values in
                radius = values.last ?? 16
            }
            .onPreferenceChange(WindowTitleKey.self){ values in
                state.setTitle(values.last ?? "")
            }
            .onAppear(perform: state.onappear)
            .environment(\._performWindowAction){ state.perform(action: $0) }
            .onChangePolyfill(of: radius){
                state.set(radius: radius)
            }
    }
    
}

#endif
