import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowRootView<Content: View>: View {
    
    @State private var title: String?
    @State private var radius: CGFloat = 10
    
    @ObservedObject var state: WindowState
    
    let content: Content
    
    var body: some View {
        content
            .containerShape(RoundedRectangle(cornerRadius: radius))
            .environment(\._windowIsKey, state.isKey)
            .onPreferenceChange(WindowCornerRadiusKey.self){ values in
                _radius.wrappedValue = values.last ?? 16
            }
            .onPreferenceChange(WindowTitleKey.self){ values in
                _title.wrappedValue = values.last
            }
            .onAppear(perform: state.onappear)
            .environment(\._performWindowAction){ state.perform(action: $0) }
            .onChangePolyfill(of: radius){
                state.set(radius: radius)
            }
            .onChangePolyfill(of: title){
                state.setTitle(title ?? "")
            }
    }
    
}

#endif
