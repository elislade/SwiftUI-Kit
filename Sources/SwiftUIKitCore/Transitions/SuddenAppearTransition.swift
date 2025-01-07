import SwiftUI


public extension AnyTransition {
    
    static func suddenAppear(at threshold: Double = 0.5) -> AnyTransition {
        .modifier(
            active: SuddenAppearModifier(progress: 0, threshold: threshold),
            identity: SuddenAppearModifier(progress: 1, threshold: threshold)
        )
    }
    
}


struct SuddenAppearModifier: ViewModifier & Animatable {
    
    var isShown: Bool
    var progress: Double
    let threshold: Double
    
    public typealias AnimatableData = Double
    
    nonisolated var animatableData: AnimatableData {
        get { progress }
        set {
            progress = newValue
        }
    }
    
    nonisolated init(progress: Double, threshold: Double) {
        self.isShown = progress > threshold
        self.progress = progress
        self.threshold = threshold
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(progress > threshold ? 1 : 0)
    }
    
}
