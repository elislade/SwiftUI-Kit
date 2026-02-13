import SwiftUIKit


public struct LoadingExamples: View {
    
    @State private var layoutDirection: LayoutDirection = .leftToRight
    @State private var loadingIndefinite = true
    @State private var loadingProgress: Double = 0.5
    
    private var loadingState: LoadingState {
        if loadingIndefinite {
            .indefinite
        } else {
            .progress(loadingProgress)
        }
    }
    
    public init() {}
    
    public var body: some View {
        ExampleView(title: "Loading"){
            VStack(spacing: 30) {
                LoadingCircle(state: loadingState)
                    .frame(width: 60)
                
                LoadingLine(state: loadingState)
                    .frame(height: 12)
            }
            .padding()
            .environment(\.layoutDirection, layoutDirection)
            .animation(.smooth, value: loadingState)
            .frame(maxWidth: 600)
        } parameters: {
            ExampleSection(isExpanded: true){
                Toggle(isOn: $loadingIndefinite){
                    Text("Indefinite")
                }
                
                ExampleSlider(value: .init($loadingProgress)){
                    Text("Progress")
                }
                .onChangePolyfill(of: loadingProgress){
                    loadingIndefinite = false
                }
                
                ExampleCell.LayoutDirection(value: $layoutDirection)
            } label: {
                Text("Parameters")
            }
        }
    }
    
}


#Preview("Loading") {
    LoadingExamples()
        .previewSize()
}
