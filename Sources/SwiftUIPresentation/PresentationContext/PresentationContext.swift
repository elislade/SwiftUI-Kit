import SwiftUI


public extension View {

    func presentationContext() -> some View {
        basicPresentationContext()
            .anchorPresentationContext()
            .focusPresentationContext()
            .presentationMatchContext()
            .ignoresSafeArea()
    }
    
}

