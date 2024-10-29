import SwiftUI

struct TrafficLightsView: View {
    
    @State private var hovering = false
    
    let close: () -> Void
    let minimize: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Button(action: close){
                ZStack {
                    Circle().fill(.red)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 7).weight(.heavy))
                        .opacity(hovering ? 0.6 : 0)
                    
                    Circle()
                        .strokeBorder(Color.primary)
                        .opacity(0.3)
                }
                .frame(width: 14, height: 14)
                .drawingGroup()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.black)
            
            Button(action: minimize){
                ZStack {
                    Circle().fill(.orange)
                    
                    Image(systemName: "minus")
                        .font(.system(size: 7).weight(.heavy))
                        .opacity(hovering ? 0.6 : 0)
                    
                    Circle()
                        .strokeBorder(Color.primary)
                        .opacity(0.3)
                }
                .frame(width: 14, height: 14)
                .drawingGroup()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.black)
            
            Circle()
                .strokeBorder()
                .frame(width: 14, height: 14)
                .opacity(0.2)
            
        }
        .onHover{ hovering = $0 }
    }
}

#Preview {
    TrafficLightsView(close: {}, minimize: {})
        .padding()
}

#if canImport(AppKit)

public struct MacTrafficLightsView: View {
    
    @Environment(\.windowIsKey) private var windowIsKey
    @Environment(\.performWindowAction) private var performWindowAction
    
    public init(){ }
    
    public var body: some View {
        TrafficLightsView(
            close: { performWindowAction(.close) },
            minimize: { performWindowAction(.minimize) }
        )
        .grayscale(windowIsKey ? 0 : 1)
    }
}


#endif
