import SwiftUI

public struct LoadingCircle: View {
    
    let state: LoadingState
    
    @State private var start: CGFloat = 0
    @State private var end: CGFloat = 0.2
    @State private var rotation: CGFloat = 0
    
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
        .easeIn(duration: 1.28)
    }
    
    public init(state: LoadingState = .indefinite) {
        self.state = state
    }
    
    private func toggle() {
        withAnimation(.linear(duration: 1.4)){
            rotation += 360
        }
        
        if end == 0.2 {
            withAnimation(animation){
                end = 0.9
            }
        } else {
            withAnimation(animation){
                end = 0.2
            }
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let scaleFactor = proxy.size.width / 45
            let size = (proxy.size.width / 5) - scaleFactor
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: size)
                    .opacity(0.1)
                
                let shape = Circle()
                    .inset(by: size / 2)
                    .trim(from: stateStart, to: stateEnd)
                    .rotation(.degrees(rotation))
                    .stroke(style: .init(lineWidth: size * 0.8, lineCap: .round))
                
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                    shape
                        .fill(
                            .tint
                                .shadow(.inner(color: .white, radius: 0.5, y: (size / 20)))
                                .shadow(.inner(radius: 0.5, y: -(size / 20)))
                                .blendMode(.overlay)
                        )
                } else {
                    shape
                        .fill(.tint)
                }
            }
            //.rotationEffect(.degrees(rotation))
            //FIXME: .layoutDirectionMirror()
        }
        .aspectRatio(1, contentMode: .fit)
        .drawingGroup()
        .onReceive(Timer.every(1.3).autoconnect()){ _ in
            if state == .indefinite {
                toggle()
            }
        }
        .onChangePolyfill(of: state, initial: true){
            if state == .indefinite {
                toggle()
            }
        }
    }
}


public struct LoadingCircleProgressStyle: ProgressViewStyle {

    public func makeBody(configuration: Configuration) -> some View {
        LoadingCircle(
            state: .init(configuration.fractionCompleted)
        )
    }
    
}


public extension ProgressViewStyle where Self == LoadingCircleProgressStyle {
    
    static var swiftUIKitCircular: LoadingCircleProgressStyle { Self() }
    
}
