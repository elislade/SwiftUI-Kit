import SwiftUI

#if canImport(UIKit)

extension VisualEffectView : UIViewRepresentable {
    
    func sync(_ v: CustomVisualEffectView) {
        if blurRadius != v.blurRadius {
            v.blurRadius = blurRadius
        }
        
        if v.disableFilters != disableFilters {
            v.disableFilters = disableFilters
        }
    }
    
    public func makeUIView(context: Context) -> CustomVisualEffectView {
        let v = CustomVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        sync(v)
        return v
    }
    
    public func updateUIView(_ uiView: CustomVisualEffectView, context: Context) {
        sync(uiView)
    }
    
}

public final class CustomVisualEffectView: UIVisualEffectView {
    
    var disableFilters: Set<VisualEffectView.Filter> = [] {
        didSet { updateFilters() }
    }
    
    var blurRadius: CGFloat? {
        didSet { updateFilters() }
    }
    
    private func updateFilters() {
        contentView.backgroundColor = .clear

        #if targetEnvironment(macCatalyst)
        guard let caFilters =  layer.sublayers?[0].sublayers?[0].sublayers?[0].filters as? [NSObject]
        else {
            return
        }
        
        #else
        
        guard let layers = layer.sublayers, let caFilters = layers[0].filters as? [NSObject]
        else {
            return
        }
        
        #endif

        caFilters.forEach {
            let name = $0.value(forKey: "name") as! String
            
            if let filter = VisualEffectView.Filter(rawValue: name) {
                $0.setValue(!disableFilters.contains(filter), forKey: "enabled")
                
                if filter == .gaussianBlur {
                    $0.setValue(blurRadius ?? 29.5, forKey: "inputRadius")
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateFilters()
    }
    
}

#endif
