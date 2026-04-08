import SwiftUI


#if os(watchOS) || os(tvOS)

extension View {
    
    // Shimed blank API Surface for callsite compatability on platforms that currently don't support the concept of hovering.
    @_disfavoredOverload
    nonisolated public func onHover(perform action: (Bool) -> Void) -> some View {
        self
    }
    
}

#endif

#if os(tvOS)

// Shimed placeholder DragGesture to allow for reuse of code that may reference a DrageGesture but othewise will work fine on a tvOS focus system.
public struct DragGesture : Gesture {
    
    public var body: _MapGesture<TapGesture, Value> {
        TapGesture()
            .map{ _ in
                Value(
                    time: Date(),
                    location: .zero,
                    startLocation: .zero
                )
            }
    }
    
    public struct Value : Equatable, Sendable {
        
        public var time: Date
        public var location: CGPoint
        public var startLocation: CGPoint
        
        public var translation: CGSize { .zero }
        public var velocity: CGSize { .zero }
        public var predictedEndLocation: CGPoint { .zero }
        public var predictedEndTranslation: CGSize { .zero }
        
    }
    
    public init(
        minimumDistance: CGFloat = 10,
        coordinateSpace: CoordinateSpace = .local
    ){
        
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        minimumDistance: CGFloat = 10,
        coordinateSpace: some CoordinateSpaceProtocol = .local
    ){
        
    }
    
}


extension LongPressGesture {
    
    nonisolated public init(
        minimumDuration: CGFloat,
        maximumDistance: CGFloat
    ){
        self.init(minimumDuration: minimumDuration)
    }
    
}


#endif
