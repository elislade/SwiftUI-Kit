import SwiftUI
    
public protocol PlacholderBacked {
    associatedtype Placeholder: View
    var placeholder: Placeholder { get }
}

///  Loads a view only if it's currently onscreen after a given delay.
///  If the provided view conforms to PlaceholderBacked the placeholder view will automatically be shown when not loaded.
///
///  - Note: Useful for improving scroll performance with long LazyList's that depend on asynchronos data loading.
public struct DelayLoadedView<Content: View, Placeholder: View>: View {
    
    @State private var show = false
    @State private var onscreen = false
    @State private var pending = false
    @State private var rect: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10)
    
    let delay: TimeInterval
    let parentGeo: GeometryProxy
    let content: () -> Content
    let placeholder: () -> Placeholder
    
    
    /// Initializes an instance
    /// - Parameters:
    ///   - delay: The amount of time to wait before checking whether the view is still onscreen.
    ///   - parentGeo: The geometry representing the parent.
    ///   - content: The view that will show if still onscreen.
    ///   - placeholder: The view that will show when waiting to check if onscreen.
    public init(
        delay: TimeInterval = 0.6,
        parentGeo: GeometryProxy,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.delay = delay
        self.parentGeo = parentGeo
        self.content = content
        self.placeholder = placeholder
    }
    
    private func tryLoad() {
        if !pending {
            pending = true
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.pending = false
                if parentGeo.frame(in: .global).intersects(rect) {
                    self.show = true
                } else {
                    self.onscreen = false
                }
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if show {
                content()
            } else {
                placeholder()
            }
        }
        .boundsChange(in: parentGeo){ bounds in
            rect = bounds
            if !onscreen {
                if parentGeo.frame(in: .global).intersects(bounds) {
                    onscreen = true
                    tryLoad()
                }
            }
        }
    }
}

public extension DelayLoadedView where Content: PlacholderBacked, Placeholder == Content.Placeholder {
    
    init(parentGeo: GeometryProxy, content: @escaping () -> Content) {
        self.init(parentGeo: parentGeo, content: content, placeholder: { content().placeholder })
    }
    
}


#Preview {
    GeometryReader { p in
        ScrollView([.horizontal, .vertical]) {
            LazyVGrid(columns: [.init()], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0) {
                ForEach(0..<100){ i in
                    DelayLoadedView(delay: 1.5, parentGeo: p) {
                        Text("Items")
                            .font(.title)
                    } placeholder: {
                        Text("Items")
                            .font(.title)
                            .redacted(reason: .placeholder)
                    }.padding()
                }
            }
        }
    }
}
