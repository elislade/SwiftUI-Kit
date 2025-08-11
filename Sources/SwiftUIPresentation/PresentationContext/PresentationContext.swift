import SwiftUI


public extension View {

    nonisolated func presentationContext() -> some View {
        basicPresentationContext()
            .anchorPresentationContext()
            .focusPresentationContext()
            .presentationMatchContext()
    }
    
}

