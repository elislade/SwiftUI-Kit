import SwiftUIKit


public struct GlyphRunExample: View {
    
    @State private var animating = false
    @State private var run = GlyphRun(
        "Glyph Shape",
        font: OSFont.systemFont(ofSize: 10, weight: .heavy)
    )
    
    public init(){ }
    
    public var body: some View {
        VStack {
            ZStack {
                run.fill(.secondary)
                
                run.stroke(
                    style: .init(
                        lineWidth: 1,
                        lineCap: .round,
                        lineJoin: .bevel,
                        dash: [2, 4],
                        dashPhase: animating ? 6 : 0
                    )
                )
                .opacity(0.3)
                .animation(
                    .linear(duration: 0.8).repeatForever(autoreverses: false),
                    value: animating
                )
            }
        }
        .padding()
        .onAppear{ animating = true }
    }
    
}


#Preview {
    GlyphRunExample()
        .previewSize()
}
