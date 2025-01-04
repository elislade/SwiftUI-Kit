import SwiftUI

#if canImport(AppKit)  && !targetEnvironment(macCatalyst)

extension VisualEffectView : NSViewRepresentable {
    
    func sync(_ v: CustomVisualEffectView) {
        if blurRadius != v.blurRadius {
            v.blurRadius = blurRadius
        }
        
        if v.disableFilters != disableFilters {
            v.disableFilters = disableFilters
        }
    }
    
    public func makeNSView(context: Context) -> CustomVisualEffectView {
        let view = CustomVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .withinWindow
        sync(view)
        return view
    }
    
    public func updateNSView(_ nsView: CustomVisualEffectView, context: Context) {
        sync(nsView)
    }
    
}

public class CustomVisualEffectView : NSVisualEffectView {
    
    var disableFilters: Set<VisualEffectView.Filter> = [] {
        didSet { updateFilters() }
    }
    
    var blurRadius: Double? {
        didSet { updateFilters() }
    }
    
    private func updateFilters() {
        layer?.backgroundColor = .clear
        
        for layer in layer?.sublayers?[0].sublayers ?? [] {
            layer.backgroundColor = .clear
        }
        
        guard let layers = layer?.sublayers?[0].sublayers, let caFilters = layers[0].filters as? [NSObject]
        else { return }
        
        caFilters.forEach {
            let name = $0.value(forKey: "name") as! String
            
            if let filter = VisualEffectView.Filter(name) {
                $0.setValue(!disableFilters.contains(filter), forKey: "enabled")
                
                if filter == .gaussianBlur {
                    $0.setValue(blurRadius ?? 30, forKey: "inputRadius")
                }
            }
        }
    }
    
    public override func updateLayer() {
        super.updateLayer()
        updateFilters()
    }
    
}

#endif
