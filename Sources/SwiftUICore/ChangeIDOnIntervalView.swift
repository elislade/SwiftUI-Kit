import SwiftUI


/// Changes a views identity at a given interval.
/// This should be used with caution and only when other means of triggering view updates won't work.
/// Invalidating identity means teardown and setup of view for every interval instead of updating its state.
public struct ChangeIDOnIntervalView<Content: View>: View {
    
    @Namespace private var ns
    @State private var update = true
    
    private let interval: TimeInterval
    private let active: Bool
    private let content: () -> Content
    
    
    /// - Parameters:
    ///   - interval: The duration in seconds of how long to wait before updating. Defaults to 1 second.
    ///   - active: A bool indicating whether to currently apply id changes. Defaults to true.
    ///   - label: The view to update.
    public init(
        interval: TimeInterval = 1,
        active: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.interval = interval
        self.active = active
        self.content = content
    }
    
    public var body: some View {
        content()
            .id("\(ns.hashValue)_\(update)")
            .background{
                if active {
                    Color.clear.onReceive(Timer.every(interval).autoconnect()){ _ in
                        update.toggle()
                    }
                }
            }
    }
    
}


#Preview {
    InlineBinding(true){ binding in
        ChangeIDOnIntervalView(active: binding.wrappedValue) {
            Text(Date(), format: .dateTime)
                .monospacedDigit()
                .padding()
                .foregroundStyle(.white)
                .background(Color.random)
                .onTapGesture {
                    binding.wrappedValue.toggle()
                }
        }
    }
}

