import SwiftUI

#if canImport(AppKit)  && !targetEnvironment(macCatalyst)

extension BlurEffectView : NSViewRepresentable {
    
    @MainActor func sync(_ native: NativeBlurEffectView) {
        var needsUpdate = false
        
        if native.blurRadius != blurRadius {
            native.blurRadius = blurRadius
            needsUpdate = true
        }
        
        if native.filtersDisabled != filtersDisabled {
            native.filtersDisabled = filtersDisabled
            needsUpdate = true
        }
        
        if needsUpdate {
            native.updateFilters()
        }
    }
    
    public func makeNSView(context: Context) -> NativeBlurEffectView {
        NativeBlurEffectView(filtersDisabled: filtersDisabled, blurRadius: blurRadius)
    }
    
    public func updateNSView(_ nsView: NativeBlurEffectView, context: Context) {
        sync(nsView)
    }
    
}

public class NativeBlurEffectView : NSVisualEffectView {
    
    convenience init(filtersDisabled: BlurEffectView.Filters, blurRadius: Double? = nil) {
        self.init(frame: .infinite)
        self.material = .hudWindow
        self.blendingMode = .withinWindow
        self.filtersDisabled = filtersDisabled
        self.blurRadius = blurRadius
    }
    
    var filtersDisabled: BlurEffectView.Filters = []
    var blurRadius: Double?
    
    func updateFilters() {
        layer?.enumerate{ layer in
            layer.backgroundColor = .none
            if let filters = layer.filters, let caFilters = filters as? [NSObject], !caFilters.isEmpty {
                filtersDisabled.update(filters: caFilters, blurRadius: blurRadius)
            }
            return false
        }
    }
    
    public override func updateLayer() {
        super.updateLayer()
        updateFilters()
    }
    
}

#endif
