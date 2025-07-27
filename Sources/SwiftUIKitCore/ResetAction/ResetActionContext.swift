import SwiftUI


struct ResetActionContext: ViewModifier {
    
    @State private var resetAction: ResetAction?
    
    func body(content: Content) -> some View {
        content
            .environment(\.reset){ amount in
                switch amount {
                case .once:
                    resetAction?()
                case .all:
                    Task {
                        while let resetAction {
                            resetAction()
                            try await Task.sleep(nanoseconds: nanoseconds(seconds: 0.05))
                        }
                    }
                }
            }
            .childResetAction{ resetAction = $0 }
            .disableResetAction()
    }
    
}

public extension EnvironmentValues {
    
    @Entry var reset: (ResetAmount) -> Void = { _ in }
    
}


public enum ResetAmount: Equatable, Sendable, BitwiseCopyable {
    case once
    case all
}
