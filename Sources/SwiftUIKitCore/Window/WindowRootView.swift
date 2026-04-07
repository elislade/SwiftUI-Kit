import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

struct WindowRootView<Content: View>: View {
    
    @State private var title: String?
    @State private var zIndex: WindowZIndex = .normal
    @State private var pickerPositioning: WindowPickerPositioning = .managed
    @State private var dockTile: DockTilePreference?
    
    @ObservedObject var state: WindowState
    
    let content: Content
    
    var body: some View {
        content
            .environment(\.windowIsKey, state.isKey)
            .onPreferenceChange(WindowTitleKey.self){ values in
                title = values.last
            }
            .onPreferenceChange(WindowIndexPreference.self){ values in
                if let values {
                    zIndex = values
                }
            }
            .onPreferenceChange(WindowPickerPositioningPreference.self){ values in
                if let values {
                    pickerPositioning = values
                }
            }
            .onPreferenceChange(WindowDockTilePreferenceKey.self){ values in
                if let values {
                    dockTile = values
                }
            }
            .environment(\.performWindowAction){ state.perform(action: $0) }
            .environment(\.scenePhase, state.phase)
            .onChange(of: title){
                state.setTitle(title ?? "")
            }
            .onChange(of: zIndex){
                state.set(index: zIndex)
            }
            .onChange(of: pickerPositioning){
                state.set(positioning: pickerPositioning)
            }
            .onChange(of: dockTile){
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

