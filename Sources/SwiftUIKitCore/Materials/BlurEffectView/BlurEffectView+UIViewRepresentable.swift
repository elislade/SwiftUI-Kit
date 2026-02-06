import SwiftUI

#if canImport(UIKit) && !os(watchOS)

extension BlurEffectView : UIViewRepresentable {
    
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
    
    public func makeUIView(context: Context) -> NativeBlurEffectView {
        NativeBlurEffectView(filtersDisabled: filtersDisabled, blurRadius: blurRadius)
    }
    
    public func updateUIView(_ uiView: NativeBlurEffectView, context: Context) {
        sync(uiView)
    }
    
}

public final class NativeBlurEffectView : UIVisualEffectView {
    
    convenience init(filtersDisabled: BlurEffectView.Filters, blurRadius: Double?) {
        #if os(tvOS)
        self.init(effect: UIBlurEffect(style: .regular))
        #else
        self.init(effect: UIBlurEffect(style: .systemMaterial))
        #endif
        
        self.filtersDisabled = filtersDisabled
        self.blurRadius = blurRadius
    }
    
    var filtersDisabled: BlurEffectView.Filters = []
    var blurRadius: Double?
    
    func updateFilters() {
        layer.enumerate{ layer in
            layer.backgroundColor = .none
            if let filters = layer.filters, let caFilters = filters as? [NSObject], !caFilters.isEmpty {
                filtersDisabled.update(filters: caFilters, blurRadius: blurRadius)
            }
            return false
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateFilters()
    }
    
}

#endif
