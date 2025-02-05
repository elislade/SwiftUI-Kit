import SwiftUI

#if os(macOS)

@MainActor final class DockTileUpdater {
    
    weak var dockTile: NSDockTile?
    
    private var previousPreference: DockTilePreference?
    
    func update(with preference: DockTilePreference?) {
        guard let dockTile else { return }
        
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.previousPreference = preference
            }
        }
        
        if previousPreference != nil && preference == nil {
            DispatchQueue.main.async { [dockTile] in
                dockTile.contentView = nil
            }
        } else if let preference, previousPreference == nil {
            DispatchQueue.main.async { [dockTile] in
                dockTile.contentView = NSHostingView(rootView: preference.view)
            }
        } else if let preference, let previousPreference {
            DispatchQueue.main.async { [dockTile] in
                if preference.id != previousPreference.id {
                    dockTile.contentView = NSHostingView(rootView: preference.view)
                } else if preference.updateValue != previousPreference.updateValue {
                    dockTile.contentView = NSHostingView(rootView: preference.view)
                    dockTile.display()
                }
            }
        }
    }
    
}

#endif
