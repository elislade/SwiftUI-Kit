import SwiftUI


#if canImport(AppKit) && !targetEnvironment(macCatalyst)

extension ViewSnapshoter: NSViewRepresentable {
    
    @MainActor func makeNSView(context: Context) -> some NSView {
        if !initial {
            context.coordinator.lastValue = value
        }
        let v = NSHostingView(rootView: content)
        //v.backgroundColor = .clear
        return v
    }
    
    @MainActor func updateNSView(_ nsView: NSViewType, context: Context) {
        if context.coordinator.lastValue != value {
            Task { @MainActor in
                if let rep = nsView.bitmapImageRepForCachingDisplay(in: nsView.bounds){
                    nsView.cacheDisplay(in: nsView.bounds, to: rep)
                    let image = NSImage(size: nsView.bounds.size)
                    image.addRepresentation(rep)
                    action(AnyView(Image(nsImage: image)))
                }
            }
            context.coordinator.lastValue = value
        }
    }
    
}

#endif
