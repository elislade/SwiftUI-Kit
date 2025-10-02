import SwiftUIKit


public struct GlyphRunExample: View {
    
    @State private var animating = false
    @State private var run = GlyphRun(
        "Abc.",
        font: OSFont.systemFont(ofSize: 10, weight: .heavy)
    )
    
    public init(){ }
    
    public var body: some View {
        ExampleView("Glyph Run"){
            ZStack {
                run.fill(.tint)
                
                run.stroke(
                    style: .init(
                        lineWidth: 2,
                        lineCap: .round,
                        lineJoin: .bevel,
                        dash: [2, 4],
                        dashPhase: animating ? 6 : 0
                    )
                )
            }
            .geometryGroupPolyfill()
            .padding()
            .onAppear{
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)){
                    animating = true
                }
            }
        }
    }
    
}


#Preview {
    GlyphRunExample()
        .previewSize()
}
