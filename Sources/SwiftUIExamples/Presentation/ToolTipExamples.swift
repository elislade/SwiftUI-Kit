import SwiftUIKit


struct ToolTipExamples: View {
        
    @State private var isPresented = false
    @State private var edge: Edge = .top
    
    var body: some View {
        ExampleView(title: "Tool Tip"){
            ZStack {
                Color.clear
                
                Image(systemName: "car")
                    .scaleEffect(isPresented ? 1.2 : 1)
                    .font(.title)
                    .toolTip(edge: edge, isPresented: $isPresented){
                        Text("Car go vroom vroom! 🚗")
                            .font(.caption)
                            .padding(5)
                    }
            }
            .animation(.bouncy, value: isPresented)
            .toolTipContext()
        } parameters: {
            Toggle(isOn: $isPresented){
                Text("Presented")
                    .font(.exampleParameterTitle)
            }
            .padding()
            
            Divider()
            
            HStack {
                Text("Edge")
                    .font(.exampleParameterTitle)
                
                Spacer()
                
                Picker("", selection: $edge){
                    ForEach(Edge.allCases, id: \.self){
                        Text("\($0)".capitalized).tag($0)
                    }
                }
            }
            .padding()
            
            Divider()
        }
    }
    
}


#Preview {
    ToolTipExamples()
}
