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
            }
            .padding()
            .environment(\.layoutDirection, layoutDirection)
            .animation(.smooth, value: loadingState)
        } parameters: {
            Toggle(isOn: $loadingIndefinite){
                Text("Indefinite")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            VStack {
                HStack {
                    Text("Progress")
                        .font(.exampleParameterTitle)
                    
                    Spacer()
                    
                    Text(loadingProgress, format: .number.rounded(increment: 0.1))
                        .font(.exampleParameterValue)
                }
                
                Slider(value: $loadingProgress)
            }
            .padding()
            .onChange(of: loadingProgress){ _ in
                loadingIndefinite = false
            }
            
            Divider()
            
            ExampleCell.LayoutDirection(value: $layoutDirection)
            
        }
    }
    
}


#Preview("Loading") {
    LoadingExamples()
        .previewSize()
}
