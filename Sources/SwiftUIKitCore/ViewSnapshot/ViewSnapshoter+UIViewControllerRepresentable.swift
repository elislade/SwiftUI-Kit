import SwiftUI


#if canImport(UIKit) && !os(watchOS)

extension ViewSnapshoter: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIHostingController<Content>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        if !initial {
            context.coordinator.lastValue = value
        }
        
        let c = UIHostingController(rootView: content)
        c.view.backgroundColor = .clear
        return c
    }
    
    @MainActor func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if context.coordinator.lastValue != value {
            Task { @MainActor in
                let format = UIGraphicsImageRendererFormat.preferred()
                format.scale = context.environment.displayScale
                let renderer = UIGraphicsImageRenderer(size: uiViewController.view.bounds.size, format: format)
                let image = renderer.image { ctx in
                    uiViewController.view.drawHierarchy(in: uiViewController.view.bounds, afterScreenUpdates: false)
                }
                
                action(AnyView(Image(uiImage: image).resizable()))
            }
            
            context.coordinator.lastValue = value
        }
    }
    
}

#endif
