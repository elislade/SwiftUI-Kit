import SwiftUI


public struct LoadingLine: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    
    let cap: CGLineCap
    let state: LoadingState
    
    @State private var start: CGFloat = 0
    @State private var end: CGFloat = 0.01
    
    private var stateStart: CGFloat {
        switch state {
        case .progress: 0
        case .indefinite: start
        }
    }
    
    private var stateEnd: CGFloat {
        switch state {
        case .progress(let amount): amount
        case .indefinite: end
        }
    }
    
    private var animation: Animation {
        .easeInOut(duration: 1.1)
    }
    
    public init(cap: CGLineCap = .round, state: LoadingState = .indefinite) {
        self.cap = cap
        self.state = state
    }
    
    private func toggle() {
        if start == 0 {
            withAnimation(animation){
                end = 1
            }
            
            withAnimation(animation.delay(0.3)){
                start = 0.99
            }
        } else {
            withAnimation(animation){
                start = 0
            }
            
            withAnimation(animation.delay(0.3)){
                end = 0.01
            }
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let shape = LineShape(axis: .horizontal)
                .trim(from: stateStart, to: stateEnd)
                .stroke(style: .init(lineWidth: height, lineCap: cap))
            
            LineShape(axis: .horizontal)
                .stroke(Color.primary.opacity(0.1), style: .init(lineWidth: height, lineCap: cap))
                .padding(.horizontal, height / 2)
                
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                shape
                    .fill(
                        .tint
                            .shadow(.inner(color: .white.opacity(0.6), radius: 0, y: height / 12))
                            .shadow(.inner(color: .black.opacity(0.2), radius: 0, y: -(height / 12)))
                            .blendMode(.overlay)
                    )
                    .padding(.horizontal, height / 2)
                
            } else {
                shape.fill(.tint)
                    .padding(.horizontal, height / 2)
            }
        }
        .layoutDirectionMirror()
        .drawingGroup()
        .onReceive(Timer.every(1.3).autoconnect()){ _ in
            toggle()
        }
        .onAppear { toggle() }
        .onChange(of: state){
            if $0 == .indefinite {
                toggle()
            }
        }
    }
    
}


public struct LoadingLineProgressStyle: ProgressViewStyle {

    public func makeBody(configuration: Configuration) -> some View {
        LoadingLine(
            state: .init(configuration.fractionCompleted)
        )
    }
    
}


public extension ProgressViewStyle where Self == LoadingCircleProgressStyle {
    
    static var swiftUIKitLine: LoadingCircleProgressStyle { Self() }
    
}
