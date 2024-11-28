import SwiftUI

public struct TrafficLightsView: View {
    
    @State private var hovering = false
    
    let axis: Axis
    
    public init(axis: Axis = .horizontal){
        self.axis = axis
    }
    
    public var body: some View {
        AxisStack(axis, spacing: 6) {
            WindowButtonClose()
            WindowButtonMinimize()
            WindowButtonZoom()
        }
        .onHover{ hovering = $0 }
        .isHighlighted(hovering)
    }
}


#Preview {
    VStack {
        TrafficLightsView()
            .buttonStyle(.windowMain)
        
        TrafficLightsView()
            .buttonStyle(.windowPanel)
    }
    .padding()
}
