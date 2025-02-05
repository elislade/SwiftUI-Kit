import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowRootView<Content: View>: View {
    
    @State private var title: String?
    @State private var radius: CGFloat = 10
    @State private var zIndex: WindowZIndex = .normal
    @State private var pickerPositioning: WindowPickerPositioning = .managed
    @State private var dockTile: DockTilePreference?
    
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
            .onPreferenceChange(WindowIndexPreference.self){ values in
                if let values {
                    _zIndex.wrappedValue = values
                }
            }
            .onPreferenceChange(WindowPickerPositioningPreference.self){ values in
                if let values {
                    _pickerPositioning.wrappedValue = values
                }
            }
            .onPreferenceChange(WindowDockTilePreferenceKey.self){ values in
                if let values {
                    _dockTile.wrappedValue = values
                }
            }
            .environment(\._performWindowAction){ state.perform(action: $0) }
            .environment(\.scenePhase, state.phase)
            .onChangePolyfill(of: radius){
                state.set(radius: radius)
            }
            .onChangePolyfill(of: title){
                state.setTitle(title ?? "")
            }
            .onChangePolyfill(of: zIndex){
                state.set(index: zIndex)
            }
            .onChangePolyfill(of: pickerPositioning){
                state.set(positioning: pickerPositioning)
            }
            .onChangePolyfill(of: dockTile){
                if let dockTile {
                    state.set(dockTile: dockTile)
                }
            }
            .onAppear {
                state.restore()
            }
    }
    
}

#endif

