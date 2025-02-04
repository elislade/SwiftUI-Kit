import SwiftUI


#if os(macOS)

struct AppDockTileModifier<ID: Hashable, DockTile: View>: ViewModifier {
    
    @State private var id = UUID()
    @State private var updater = DockTileUpdater()
    
    let tileID: ID
    @ViewBuilder let tile: DockTile
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                updater.dockTile = NSApp.dockTile
            }
            .onChangePolyfill(of: tileID){
                updater.update(with: .init(
                    id: id,
                    updateValue: tileID,
                    view: AnyView(tile)
                ))
            }
    }
    
}

#endif
